//
//  SplashViewController.m
//  SASlideMenu
//
//  Created by Igor Alefirenko on 22/08/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "SplashViewController.h"
#import "FBStorage.h"
#import "FBService.h"
#import "Reachability.h"
#import "LocationService.h"
#import "QBService.h"
#import "QBStorage.h"


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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setBackgroundImage:nil];
    [self setLoginButton:nil];
    [self setActivityIndicatior:nil];
    [super viewDidUnload];
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
    
    if ([FBSession activeSession].state == FBSessionStateCreated) {
        
        //Show FB login dialog
        [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorWithFallbackToWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (status == FBSessionStateClosedLoginFailed) {
                [FBService shared].session = [[FBSession alloc] init];
                [FBSession setActiveSession:[FBService shared].session];
                NSLog(@"Error!");
                
            } else {
                [self hideLoginButton:YES];
                [self.activityIndicatior startAnimating];
                
                // save FB Token
                [[FBStorage shared] saveFBToken:[FBService shared].session.accessTokenData.accessToken];
                [FBStorage shared].accessToken = [FBService shared].session.accessTokenData.accessToken;
                
                // login to FB XMPP Chat
                [self loginToFacebookChat];
                
                // create QB session
                [self createQBSessionWithSocialProvider:kFacebookKey andAccessToken:GetFBAccessToken];
                
                [self gettingAllDataAboutMeAndMyFriendsFromFacebook];
                
                // Get FB Chat history
                [[FBService shared] inboxMessagesWithBlock:^(id result) {
                    NSMutableArray *resultData = [result objectForKey:kData];
                    NSMutableDictionary *history = [[NSMutableDictionary alloc] init];
                    for (NSMutableDictionary *dict in resultData) {
                        NSArray *array = [[dict objectForKey:kTo] objectForKey:kData];
                        for (NSMutableDictionary *element in array) {
                            if ([element objectForKey:kId] != [[FBStorage shared].me objectForKey:kId]) {
                                [history setObject:dict forKey:[element objectForKey:kId]];
                            }
                        }
                    }
                    [FBStorage shared].allFriendsHistoryConversation = history;
                }];
            }
        }]; 
    }

    // If FB token already received
    if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        [self hideLoginButton:YES];
        
        [FBStorage shared].accessToken = [FBService shared].session.accessTokenData.accessToken;
        
        [[FBService shared].session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            [self gettingAllDataAboutMeAndMyFriendsFromFacebook];
            
            // Get FB Chat history
            [[FBService shared] inboxMessagesWithBlock:^(id result) {
                NSMutableArray *resultData = [result objectForKey:kData];
                NSMutableDictionary *history = [[NSMutableDictionary alloc] init];
                for (NSMutableDictionary *dict in resultData) {
                    NSArray *array = [[dict objectForKey:kTo] objectForKey:kData];
                    for (NSMutableDictionary *element in array) {
                        if ([element objectForKey:kId] != [[FBStorage shared].me objectForKey:kId]) {
                            [history setObject:dict forKey:[element objectForKey:kId]];
                        }
                    }
                }
                [FBStorage shared].allFriendsHistoryConversation = history;
            }];
        }];
        
        // login to FB XMPP Chat
        [self loginToFacebookChat];
        // create QB session
        [self createQBSessionWithSocialProvider:kFacebookKey andAccessToken:GetFBAccessToken];
        
    }
    
}

- (void)gettingAllDataAboutMeAndMyFriendsFromFacebook
{
    
    [[FBService shared] userProfileWithResultBlock:^(id result) {
        
        FBGraphObject *user = (FBGraphObject *)result;
        [FBStorage shared].me = [user mutableCopy];
    }];
    
    // getting my friends:
    [[FBService shared] userFriendsUsingBlock:^(id result) {

        NSMutableArray *myFriends = [(FBGraphObject *)result objectForKey:kData];
        for (NSMutableDictionary *frend in myFriends) {
            NSString *urlString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@",[frend objectForKey:kId],[FBStorage shared].accessToken];
            [frend setValue:urlString forKey:kPhoto];
        }
        [[FBStorage shared] setFriends:myFriends];
    }];
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
        
        [[QBStorage shared] loadHistory];
        NSArray *userIDs = [[QBStorage shared].allQuickBloxHistoryConversation allKeys];
        NSMutableArray *users = [[FBService shared] userProfilesWithIDs:userIDs];
        [QBStorage shared].otherUsers = users;
        
        QBUUser *currentUser = [QBUUser user];
        currentUser.ID = res.session.userID;
        currentUser.password = res.session.token;
        [[QBStorage shared] setMe:currentUser];
        // Login to QB Chat
        [[QBService defaultService] loginWithUser:currentUser];
    }
}


#pragma mark -
#pragma mark Auth Notification

- (void)chatDidLogin
{
    [self.activityIndicatior stopAnimating];
    [self dismissModalViewControllerAnimated:YES];
}

@end
