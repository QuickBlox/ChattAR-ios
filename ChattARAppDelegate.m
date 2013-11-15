//
//  SASlideMenuAppDelegate.m
//  SASlideMenuStatic
//
//  Created by Stefano Antonelli on 12/3/12.
//  Copyright (c) 2012 Stefano Antonelli. All rights reserved.
//

#import "ChattARAppDelegate.h"
#import "AppDelegate+MemoryWarnings.h"
#import "FBService.h"
#import "QBService.h"
#import "QBStorage.h"

@implementation ChattARAppDelegate


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                    fallbackHandler:^(FBAppCall *call) {
                        NSLog(@"In fallback handler");
                    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkMemory)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    // Set QuickBlox credentials
    [QBSettings setApplicationID:771];
    [QBSettings setAuthorizationKey:@"hOYSNJ8zwYhUspn"];
    [QBSettings setAuthorizationSecret:@"KcfDYJFY7x3r5HR"];
    [QBSettings setRestAPIVersion:@"0.1.1"];
    
    
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
    if ([FBService shared].isInChatRoom == YES) {
        [[QBChat instance] leaveRoom:[[QBStorage shared] currentChatRoom]];
        [QBStorage shared].currentChatRoom = nil;
    }
    [[QBChat instance] logout];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if ([[QBStorage shared] me] != nil) {
        [[QBChat instance] loginWithUser:[[QBStorage shared] me]];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"activatechat" object:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
