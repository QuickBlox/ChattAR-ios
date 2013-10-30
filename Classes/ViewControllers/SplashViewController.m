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

@implementation SplashViewController
@synthesize backgroundImage, loginButton;


#pragma mark
#pragma mark ViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidUnload {
    [self setBackgroundImage:nil];
    [self setLoginButton:nil];
    [self setActivityIndicatior:nil];
    [super viewDidUnload];
}


#pragma mark
#pragma mark Actions

-(IBAction)logIn:(id)sender{
    
    [self checkFBSession];
}


#pragma mark -
#pragma mark Auth methods

// checking FBSession state:
-(void)checkFBSession{
    
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
            }
        }]; 
    }

    // If FB token already received
    if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        [self hideLoginButton:YES];
        
        [FBStorage shared].accessToken = [FBService shared].session.accessTokenData.accessToken;
        
        [[FBService shared].session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            [self gettingAllDataAboutMeAndMyFriendsFromFacebook];
        }];
        
        // login to FB XMPP Chat
        [self loginToFacebookChat];
        // create QB session
        [self createQBSessionWithSocialProvider:kFacebookKey andAccessToken:GetFBAccessToken];
        
    }
    
}

- (void) gettingAllDataAboutMeAndMyFriendsFromFacebook {
    
    [[FBService shared] userProfileWithResultBlock:^(id result) {
        
        FBGraphObject *user = (FBGraphObject *)result;
        [FBStorage shared].currentFBUser = [user mutableCopy];
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
-(void)loginToFacebookChat{
    [[FBService shared] logInChat];
}

// QBSession
-(void)createQBSessionWithSocialProvider:(NSString *)provider andAccessToken:(NSString *)accessToken{
    QBASessionCreationRequest *extendedRequest = [QBASessionCreationRequest request];
    extendedRequest.socialProvider = provider;
    extendedRequest.socialProviderAccessToken = accessToken;
    
    [QBAuth createSessionWithExtendedRequest:extendedRequest delegate:self];
}


#pragma mark
#pragma mark UI updates

// Show or hide login button
-(void)hideLoginButton:(BOOL)isHidden{
    self.loginButton.hidden = isHidden;
}


#pragma mark 
#pragma mark QBActionStatusDelegate

-(void)completedWithResult:(Result *)result{
    if (result.success && [result isKindOfClass:[QBAAuthSessionCreationResult class]]) {
        // session was created successful
        QBAAuthSessionCreationResult *res = (QBAAuthSessionCreationResult *)result;
        QBUUser *currentUser = [QBUUser user];
        currentUser.ID = res.session.userID;
        currentUser.password = res.session.token;
        [[QBService defaultService] setMe:currentUser];
        // Login to QB Chat
        [QBChat instance].delegate = self;
        [[QBChat instance] loginWithUser:currentUser];
    }
}


#pragma mark -
#pragma mark QBChatDelegate

-(void)chatDidLogin{
    NSLog(@"Chat login success");
    [self.activityIndicatior stopAnimating];
    [NSTimer scheduledTimerWithTimeInterval:10 target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];
    //start getting location:
    [[LocationService shared] startUpdateLocation];
    [self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidLogin object:nil];
    
    //NSLog(@"%@", [[[[FBStorage shared]friends] objectAtIndex:1] allKeys]);
}

@end
