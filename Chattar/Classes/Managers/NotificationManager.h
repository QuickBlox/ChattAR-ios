//
//  NotificationManager.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 4/2/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface NotificationManager : NSObject

+ (void)soundEnable:(BOOL)soundEnable;
+ (BOOL)isSoundEnabled;

+ (void)vibrationEnable:(BOOL)vibrationEnable;
+ (BOOL)isVibrationEnabled;

+ (void)popUpEnable: (BOOL)popUpEnable;
+ (BOOL)isPopUpEnabled;

+ (void)playNotificationSoundAndVibrate;

@end
