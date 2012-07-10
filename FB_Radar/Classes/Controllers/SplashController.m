//
//  SplashController.m
//  FB_Radar
//
//  Created by Sonny Black on 04.05.12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "SplashController.h"
#import "AppDelegate.h"
#import "NumberToLetterConverter.h"

@interface SplashController ()

@end

@implementation SplashController 

@synthesize openedAtStartApp;

#pragma mark -
#pragma mark UIViewControllers & view methods

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [QBSettings setLogLevel:QBLogLevelDebug];

    // QuickBlox application autorization
    if(openedAtStartApp){
		
        //[QBAuthService authorizeAppId:appID key:authKey secret:authSecret delegate:self];
        [activityIndicator startAnimating];
		
		NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:60*60*2-600 // Expiration date of access token is 2 hours. Repeat request for new token every 1 hour and 50 minutes.
														  target:self 
														selector:@selector(createSession) 
														userInfo:nil 
														 repeats:YES];
		[timer fire];
		
    }else{
        // show Login & Registrations buttons
        [activityIndicator stopAnimating];
        
        loginButton.hidden = NO;
    }        
}

- (void)createSession
{
	// Create extended application authorization request (for push notifications)
	QBASessionCreationRequest *extendedAuthRequest = [[QBASessionCreationRequest alloc] init];
	extendedAuthRequest.devicePlatorm = DevicePlatformiOS;
	extendedAuthRequest.deviceUDID = [[UIDevice currentDevice] uniqueIdentifier];
    if([DataManager shared].currentFBUser){
        extendedAuthRequest.userLogin = [[NumberToLetterConverter instance] convertNumbersToLetters:[[DataManager shared].currentFBUser objectForKey:kId]];
        extendedAuthRequest.userPassword = [NSString stringWithFormat:@"%u", [[[DataManager shared].currentFBUser objectForKey:kId] hash]];
    }
	
	// QuickBlox application authorization
	[QBAuthService createSessionWithAppId:appID key:authKey secret:authSecret extendedRequest:extendedAuthRequest delegate:nil];
	
	[extendedAuthRequest release];
}

- (void)viewDidUnload{
    activityIndicator = nil;
    loginButton = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Login action
- (IBAction)login:(id)sender{
    // Auth in FB
    NSArray *params = [[NSArray alloc] initWithObjects:@"user_checkins", @"user_location", @"friends_checkins",
                       @"friends_location", @"friends_status", @"read_mailbox",@"photo_upload",
                       @"publish_stream", @"user_photos", @"xmpp_login", @"user_about_me", nil];
    [[FBService shared].facebook setSessionDelegate:self];
    [[FBService shared].facebook authorize:params];
    [params release];
}


#pragma mark -
#pragma mark FBSessionDelegate

- (void)fbDidLogin {
    // save FB token and expiration date
    [[DataManager shared] saveFBToken:[FBService shared].facebook.accessToken 
                              andDate:[FBService shared].facebook.expirationDate];
    
    
    // auth in Chat
    [[FBService shared] logInChat];
    
    // get user's profile
    [[FBService shared] userProfileWithDelegate:self];
    
    [activityIndicator startAnimating];
    loginButton.hidden = YES;
}

- (void)fbDidNotLogin:(BOOL)cancelled{}
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt{}
- (void)fbDidLogout{}
- (void)fbSessionInvalidated{}


#pragma mark -
#pragma mark FBServiceResultDelegate

-(void)completedWithFBResult:(FBServiceResult *)result{
    
    // get User profile result
    if(result.queryType == FBQueriesTypesUserProfile){
        // save FB user
        [DataManager shared].currentFBUser = [[result.body mutableCopy] autorelease];
        [DataManager shared].currentFBUserId = [[DataManager shared].currentFBUser objectForKey:kId];
        
        NSLog(@" [DataManager shared].currentFBUserId =%@", [DataManager shared].currentFBUserId );
        
        // try to auth
        NSString *userLogin = [[NumberToLetterConverter instance] convertNumbersToLetters:[[DataManager shared].currentFBUser objectForKey:kId]];
        NSString *passwordHash = [NSString stringWithFormat:@"%u", [[[DataManager shared].currentFBUser objectForKey:kId] hash]];
        
        // Authenticate user
        [QBUsersService logInWithUserLogin:userLogin password:passwordHash delegate:self];
    }
}


#pragma mark -
#pragma mark QB ActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result *)result{
    
    // QuickBlox Application authorization result
    if([result isKindOfClass:[QBAAuthSessionCreationResult class]]){
        // Success result
		if(result.success){

            // FB auth
            [FBService shared].facebook.accessToken = [[[DataManager shared] fbUserTokenAndDate] objectForKey:FBAccessTokenKey];
            [FBService shared].facebook.expirationDate = [[[DataManager shared] fbUserTokenAndDate] objectForKey:FBExpirationDateKey];

            if (![[FBService shared].facebook isSessionValid]) {
                
                // show Login & Registrations buttons
                [activityIndicator stopAnimating];
                
                loginButton.hidden = NO;
            }else{
                // get user's profile
                [[FBService shared] userProfileWithDelegate:self];
                
                // auth in Chat
                [[FBService shared] logInChat];
            }
            
        // Errors
        }else{
            NSString *message = [result.errors stringValue];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Errors", nil) 
                                                            message:message  
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", nil) 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
	
	// QuickBlox User authenticate result
    }else if([result isKindOfClass:[QBUUserLogInResult class]]){
        // Success result
		if(result.success){
            QBUUserLogInResult *res = (QBUUserLogInResult *)result;
            
            // save current user
            [DataManager shared].currentQBUser = res.user;
            
			// register as subscribers for receiving push notifications
            [QBMessagesService TRegisterSubscriptionWithDelegate:self];
            
            // hide splash
            [activityIndicator stopAnimating];
            
            // show messages
            ((AppDelegate *)[[UIApplication sharedApplication] delegate]).tabBarController.selectedIndex = 0;
            
            [self dismissModalViewControllerAnimated:YES];
            
            
            // start track own loaction
            [[[QBLLocationDataSource instance] locationManager] startUpdatingLocation];

        // Errors
		}else if(401 == result.status){
            
            // Register new user
            // Create QBUUser entity
            QBUUser *user = [[QBUUser alloc] init];     
            NSString *userLogin = [[NumberToLetterConverter instance] convertNumbersToLetters:[[DataManager shared].currentFBUser objectForKey:kId]];
            NSString *passwordHash = [NSString stringWithFormat:@"%u", [[[DataManager shared].currentFBUser objectForKey:kId] hash]]; 
            user.login = userLogin;
            user.password = passwordHash;
            user.facebookID = [[DataManager shared].currentFBUser objectForKey:kId];
            user.tags = [NSArray arrayWithObject:@"Chattar"];
            
            // Create user
            [QBUsersService signUp:user delegate:self];
            [user release];

        // Errors
		}else{
            NSString *message = [result.errors stringValue];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Errors", nil) 
                                                            message:message  
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", nil) 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        
    // Create user result
    }else if([result isKindOfClass:[QBUUserResult class]]){
		
        // Success result
		if(result.success){
            
            // auth again
            NSString *userLogin = [[NumberToLetterConverter instance] convertNumbersToLetters:[[DataManager shared].currentFBUser objectForKey:kId]];
            NSString *passwordHash = [NSString stringWithFormat:@"%u", [[[DataManager shared].currentFBUser objectForKey:kId] hash]];
            
            // authenticate user
            [QBUsersService logInWithUserLogin:userLogin password:passwordHash delegate:self];
            
        // show Errors
        }else{
            NSString *message = [result.errors stringValue];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Errors", nil) 
                                                            message:message  
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", nil) 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        
	}
}

@end
