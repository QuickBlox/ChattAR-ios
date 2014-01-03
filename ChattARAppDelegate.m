//
//  ChattARAppDelegate.m
//  ChattAR
//
//  Created by Igor Alefirenko on 29/10/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "ChattARAppDelegate.h"
#import "ChattARAppDelegate+PushNotifications.h"
#import "ChattARAppDelegate+MemoryWarnings.h"
#import "LocationService.h"
#import "AppSettingsService.h"
#import "FBService.h"
#import "QBService.h"
#import "QBStorage.h"
#import "MBProgressHUD.h"
#import "Utilites.h"



@implementation ChattARAppDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                    fallbackHandler:^(FBAppCall *call) {
                        NSLog(@"In fallback handler");
                    }];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [QBStorage shared].pushNotification = userInfo;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
//    UIApplicationLaunchOptionsRemoteNotificationKey =     {
//        aps =         {
//            alert = "Oleg Svarovski: lllllloololol";
//            id = 100003078678033;
//            sound = default;
//        };
//    };
    
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:-1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkMemory)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    // Set QuickBlox credentials
    [QBSettings setApplicationID:771];
    [QBSettings setAuthorizationKey:@"hOYSNJ8zwYhUspn"];
    [QBSettings setAuthorizationSecret:@"KcfDYJFY7x3r5HR"];
#ifndef DEBUG
    [QBSettings useProductionEnvironmentForPushNotifications:YES];
    [QBSettings setLogLevel:QBLogLevelNothing];
#endif
    
    //[Flurry setLogLevel:FlurryLogLevelDebug];
    [Flurry startSession:@"B22M9PDJH4F4D2J2FVBB"];
    
    [AppSettingsService shared];
    
    NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    [QBStorage shared].pushNotification = userInfo;

    return YES;
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
    if ([QBStorage shared].joinedChatRoom != nil) {
        [[QBChat instance] leaveRoom:[QBStorage shared].joinedChatRoom];
        [[QBStorage shared] setJoinedChatRoom:nil];
        [[QBStorage shared].chatHistory removeAllObjects];
    }
    [[QBChat instance] logout];
    [[QBStorage shared] saveHistory];
    [[LocationService shared] stopUpdateLocation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    QBUUser *me = [QBStorage shared].me;
    UIWindow *currentWindow = [[UIApplication sharedApplication].windows lastObject];
    if (me == nil) {
        return;
    }
    [[QBChat instance] loginWithUser:me];
    [[QBStorage shared] loadHistory];
    
    MBProgressHUD *currentHUD = [MBProgressHUD HUDForView:currentWindow];
    if (currentHUD == nil) {
        [Utilites shared].progressHUD = [MBProgressHUD showHUDAddedTo:currentWindow animated:YES];
        [[Utilites shared].progressHUD setLabelText:@"Reconnecting..."];
        return;
    }
    if (!currentHUD.taskInProgress) {
        if (![Utilites shared].isShared) {
            [currentHUD setLabelText:@"Reconnecting..."];
        }
        [currentHUD performSelector:@selector(show:) withObject:nil];
    }
    [[AppSettingsService shared] checkSoundAndVibration];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
