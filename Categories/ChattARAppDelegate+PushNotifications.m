//
//  ChattARAppDelegate+PushNotifications.m
//  ChattAR
//
//  Created by Igor Alefirenko on 02/01/2014.
//  Copyright (c) 2014 Stefano Antonelli. All rights reserved.
//

#import "ChattARAppDelegate+PushNotifications.h"
#import "SASlideMenuRootViewController.h"
#import "FBService.h"
#import "FBStorage.h"
#import "QBService.h"
#import "QBStorage.h"

@implementation ChattARAppDelegate (PushNotifications)

- (void)processRemoteNotification:(NSDictionary *)userInfo
{
    UIApplication *application = [UIApplication sharedApplication];
    UIWindow *window = [[application delegate] window];
    SASlideMenuRootViewController *root =  (SASlideMenuRootViewController *)window.rootViewController;
    
    UINavigationController *navigationVC = [[root childViewControllers] lastObject];
    
    NSDictionary *aps = userInfo[@"aps"];
    NSString *opponentID = aps[kId];
    NSString *qbOpponentID = aps[kQuickbloxID];
    
    if (navigationVC != nil) {
        
        // Dialog:
        NSMutableDictionary *conversation = nil;
        NSMutableDictionary *user = [[[FBService shared] findFriendWithID:opponentID] mutableCopy];
        if (user != nil) {
            conversation = [FBService findFBConversationWithFriend:user];
        } else {
            user = [[QBService defaultService] findUserWithID:opponentID];
        }
        if (user == nil) {
            [[FBService shared] userProfileWithID:opponentID withBlock:^(id result) {
                //
                NSMutableDictionary *opponent = (FBGraphObject *)result;
                opponent[kQuickbloxID] = qbOpponentID;
                NSString *urlString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", opponentID, [FBStorage shared].accessToken];
                opponent[kPhoto] = urlString;
                [[QBStorage shared].otherUsers addObject:opponent];
            }];
        }
        
        UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        id viewController = [myStoryboard instantiateViewControllerWithIdentifier:@"dialogController"];
        [navigationVC pushViewController:viewController animated:YES];
    }
}

@end
