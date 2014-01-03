//
//  ChattARAppDelegate+PushNotifications.h
//  ChattAR
//
//  Created by Igor Alefirenko on 02/01/2014.
//  Copyright (c) 2014 Stefano Antonelli. All rights reserved.
//

#import "ChattARAppDelegate.h"

@interface ChattARAppDelegate (PushNotifications)

-(void)processRemoteNotification:(NSDictionary *)userInfo;

@end
