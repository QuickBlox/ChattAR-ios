//
//  AppDelegate.m
//  FB_Radar
//
//  Created by Sonny Black on 03.05.12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "AppDelegate.h"

#import "MessagesViewController.h"
#import "MapChatARViewController.h"
#import "ContactsController.h"
#import "SettingsController.h"
#import "SplashController.h"
#import "FBNavigationBar.h"
#import "FBChatViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (void)dealloc{
	[_window release];
	[_tabBarController release];
	
    [super dealloc];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
//    NSLog(@"didReceiveRemoteNotification userInfo=%@", userInfo);
//    
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "") 
//													message:@"FOO"
//												   delegate:nil 
//										  cancelButtonTitle:NSLocalizedString(@"OK", "") 
//										  otherButtonTitles:nil];
//	[alert show];
//	[alert release];
//
//    // Receive push notifications
//    NSString *message = [[userInfo objectForKey:QBMPushMessageApsKey] objectForKey:QBMPushMessageAlertKey];
//    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:message, @"message", nil];
//    
//    [[NSNotificationCenter defaultCenter]  postNotificationName:@"pushDidReceived" object:nil userInfo:info];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
	[UIApplication sharedApplication].statusBarHidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkMemory) 
                                                 name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	
	UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) 
	{
       // NSString *itemName = [localNotif.userInfo objectForKey:@"foo"];
        application.applicationIconBadgeNumber = localNotif.applicationIconBadgeNumber-1;
    }
	application.applicationIconBadgeNumber = 0;
	
	// Register for Push Notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | 
                                                                           UIRemoteNotificationTypeBadge | 
                                                                           UIRemoteNotificationTypeSound)];
	
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
    // Radar
	MapChatARViewController *mapChatARViewController = [[MapChatARViewController alloc] initWithNibName:@"MapChatARViewController" bundle:nil];
	UINavigationController* mapChatARNavigationController = [[UINavigationController alloc] initWithRootViewController:mapChatARViewController];
	[mapChatARViewController.navigationController setValue:[[[FBNavigationBar alloc]init] autorelease] forKeyPath:@"navigationBar"];
    [mapChatARViewController release];

    // Settings
	SettingsController *settingsViewController = [[SettingsController alloc] initWithNibName:@"SettingsController" bundle:nil];
    UINavigationController *settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
	[settingsViewController.navigationController setValue:[[[FBNavigationBar alloc]init] autorelease] forKeyPath:@"navigationBar"];
    [settingsViewController release];
    
    // Messages
    MessagesViewController *messagesViewController = [[MessagesViewController alloc] initWithNibName:@"MessagesViewController" bundle:nil];
	UINavigationController *messagesNavigationController = [[UINavigationController alloc] initWithRootViewController:messagesViewController];
	[messagesViewController.navigationController setValue:[[[FBNavigationBar alloc]init] autorelease] forKeyPath:@"navigationBar"];
    [messagesViewController release];
    
    // Contacts
    ContactsController *contactsViewController = [[ContactsController alloc] initWithNibName:@"ContactsController" bundle:nil];
    UINavigationController *contactsNavigationController = [[UINavigationController alloc] initWithRootViewController:contactsViewController];
	[contactsViewController.navigationController setValue:[[[FBNavigationBar alloc]init] autorelease] forKeyPath:@"navigationBar"];
    [contactsViewController release];

	// Tab Bar
	_tabBarController = [[UITabBarController alloc] init];
	_tabBarController.viewControllers = [NSArray arrayWithObjects: messagesNavigationController, mapChatARNavigationController, contactsNavigationController, settingsNavigationController, nil];
	
	// release controllers
	[settingsNavigationController release];
    [mapChatARNavigationController release];
    [messagesNavigationController release];
	[contactsNavigationController release];
	
    // show window
	self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    
    // shpw splash
    [self showSplashWithAnimation:NO];
    
    return YES;
}

- (void)showSplashWithAnimation:(BOOL) animated{
    
    // show Splash
    SplashController *splashViewController = [[SplashController alloc] initWithNibName:@"SplashController" bundle:nil]; 
    splashViewController.openedAtStartApp = !animated;
    [self.tabBarController presentModalViewController:splashViewController animated:animated];
    [splashViewController release];
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBService shared].facebook handleOpenURL:url]; 
}

// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[FBService shared].facebook handleOpenURL:url]; 
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	
	// request for access token again
	// Create extended application authorization request (for push notifications)
	QBASessionCreationRequest *extendedAuthRequest = [[QBASessionCreationRequest alloc] init];
	extendedAuthRequest.devicePlatorm = DevicePlatformiOS;
	extendedAuthRequest.deviceUDID = [[UIDevice currentDevice] uniqueIdentifier];
	
	// QuickBlox application authorization
	[QBAuthService createSessionWithAppId:appID key:authKey secret:authSecret extendedRequest:extendedAuthRequest delegate:nil];
	
	[extendedAuthRequest release];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	if (![FBService shared].isChatDidConnect && [DataManager shared].currentQBUser) // if user was disconnected in chat & he was authenticated fo FB
	{
		[[FBService shared] logInChat]; // auth to chat again
	}
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) checkMemory {
	if (printMemoryInfo() < 3) {
        [self showStartMemoryAlert];
	} 
}

@end
