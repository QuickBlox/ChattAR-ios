//
//  SplashViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 22/08/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "SplashViewController.h"
#import "FBStorage.h"
#import "FBService.h"
#import "Reachability.h"
#import "LocationService.h"
#import "QBService.h"
#import "QBStorage.h"


@interface SplashViewController () <FBLoginViewDelegate, QBActionStatusDelegate, QBChatDelegate>

@end

@implementation SplashViewController
@synthesize backgroundImage, loginButton;

#pragma mark
#pragma mark ViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidLogin) name:kNotificationDidLogin object:nil];
    // if iPhone 5
    if(IS_HEIGHT_GTE_568){
        [backgroundImage setImage:[UIImage imageNamed:@"Default-568h@2x.png"]];
    } else {
        [backgroundImage setImage:[UIImage imageNamed:@"Default@2x.png"]];
    }
    
    // if session isn't open   
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"user_checkins", @"user_location", @"friends_checkins",
                            @"friends_location", @"friends_status", @"read_mailbox",@"photo_upload",@"read_stream",
                            @"publish_stream", @"user_photos", @"xmpp_login", @"user_about_me", nil];
    if (![Reachability internetConnected]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No internet connection" message:@"Check your internet connection and try again" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        loginButton.hidden = YES;
        [alert show];
    } else {
        if (![[FBService shared].session isOpen]) {
            [FBService shared].session = [[FBSession alloc] initWithPermissions:permissions];
            [FBSession setActiveSession:[FBService shared].session];
        }

        //checkFBSession
        if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
            [self.activityIndicatior startAnimating];
            [self checkFBSession];
        }
    }
}

#pragma mark
#pragma mark Actions

- (IBAction)logIn:(id)sender
{
    [self checkFBSession];
}


#pragma mark -
#pragma mark Auth methods

// checking FBSession state:
- (void)checkFBSession
{
    // load history with users:
    [[QBStorage shared] loadHistory];
    
    if ([FBSession activeSession].state == FBSessionStateCreated) {
        
        //Show FB login dialog
        [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorWithFallbackToWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (status == FBSessionStateClosedLoginFailed) {
                [FBService shared].session = [[FBSession alloc] init];
                [FBSession setActiveSession:[FBService shared].session];
                NSLog(@"Error!");
                return;
            }
            if (status == FBSessionStateClosed) {
                // do nothing
                return;
            }
            [self hideLoginButton:YES];
            [self.activityIndicatior startAnimating];
            
            // save FB Token
            NSString *accessToken = [FBService shared].session.accessTokenData.accessToken;
            [[FBStorage shared] setAccessToken:accessToken];
            [FBStorage shared].accessToken = accessToken;
            
            // login to FB XMPP Chat
            [self loginToFacebookChat];
            
            // create QB session
            [self createQBSessionWithSocialProvider:kFacebookKey andAccessToken:[FBStorage shared].accessToken];
            
            // Get FB Chat history
            [[FBService shared] inboxMessagesWithBlock:^(id result) {
                NSMutableArray *resultData = [result objectForKey:kData];
                NSMutableDictionary *history = [[FBService shared] handleFacebookHistoryConversation:resultData];
                [FBStorage shared].allFriendsHistoryConversation = history;
            }];
            
        }]; 
    }

    // If FB token already received
    if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        [self hideLoginButton:YES];
        
        [FBStorage shared].accessToken = [FBService shared].session.accessTokenData.accessToken;
        
        [[FBService shared].session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            // Get FB Chat history
            [[FBService shared] inboxMessagesWithBlock:^(id result) {
                NSMutableArray *resultData = [result objectForKey:kData];
                NSMutableDictionary *history = [[FBService shared] handleFacebookHistoryConversation:resultData];
                [FBStorage shared].allFriendsHistoryConversation = history;
            }];
        }];
        
        // login to FB XMPP Chat
        [self loginToFacebookChat];
    
        // create QB session
        [self createQBSessionWithSocialProvider:kFacebookKey andAccessToken:[FBStorage shared].accessToken];
        
    }
}

// LogIn to XMPP
- (void)loginToFacebookChat
{
    [[FBService shared] logInChat];
}

// QBSession
- (void)createQBSessionWithSocialProvider:(NSString *)provider andAccessToken:(NSString *)accessToken
{
    QBASessionCreationRequest *extendedRequest = [QBASessionCreationRequest request];
    extendedRequest.socialProvider = provider;
    extendedRequest.socialProviderAccessToken = accessToken;
    
    [QBAuth createSessionWithExtendedRequest:extendedRequest delegate:self];
}


#pragma mark
#pragma mark UI updates

// Show or hide login button
- (void)hideLoginButton:(BOOL)isHidden
{
    self.loginButton.hidden = isHidden;
}


#pragma mark 
#pragma mark QBActionStatusDelegate

- (void)completedWithResult:(Result *)result
{
    if (result.success && [result isKindOfClass:[QBAAuthSessionCreationResult class]]) {
        // session was created successful
        QBAAuthSessionCreationResult *res = (QBAAuthSessionCreationResult *)result;
        
        // save current user
        QBUUser *currentUser = [QBUUser user];
        currentUser.ID = res.session.userID;
        currentUser.password = res.session.token;
        [FBStorage shared].me[kQuickbloxID] =  [@(currentUser.ID) stringValue];
        [[QBStorage shared] setMe:currentUser];
        
        // Login to QB Chat
        [[QBService defaultService] loginWithUser:currentUser];
        
        // subscribe user to push notifications:
        [QBMessages TRegisterSubscriptionWithDelegate:self];
        
        
        // retrieve friends/users info
        [[FBService shared] loadAndHandleDataAboutMeAndMyFriends];
        //
        NSArray *userIDs = [[QBStorage shared].allQuickBloxHistoryConversation allKeys];
        [[QBService defaultService] loadAndHandleOtherFacebookUsers:userIDs];
    }
    
    if (result.success && [result isKindOfClass:QBMRegisterSubscriptionTaskResult.class]) {
        NSLog(@"Now you can receive and send Push Notification");
    }
}


#pragma mark -
#pragma mark Notifications

- (void)chatDidLogin
{
    [Flurry logEvent:kFlurryEventUserWasLoggedIn];
    [self.activityIndicatior stopAnimating];
    [self dismissModalViewControllerAnimated:YES];
}

@end
