//
//  NotificationManager.m
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 4/2/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "NotificationManager.h"
#import "AppDelegate.h"

#define kVibrationOn @"Vibrate"
#define kSoundOn @"Sound"
#define kPopUpOn @"PopUp"

static AVAudioPlayer* audioPlayer;

@implementation NotificationManager

#pragma mark -
#pragma mark Sound

+ (void)soundEnable: (BOOL)soundEnable {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:soundEnable] forKey:kSoundOn];
    [defaults synchronize];
}

+ (BOOL)isSoundEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *enabled = [defaults objectForKey:kSoundOn];
    if(enabled == nil) {
        return YES;
    }
 
    return  [enabled boolValue];
}


#pragma mark -
#pragma mark Vibration

+ (void) vibrationEnable:(BOOL)vibrationEnable {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:vibrationEnable] forKey:kVibrationOn];
    [defaults synchronize];
}

+ (BOOL) isVibrationEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *enabled = [defaults objectForKey:kVibrationOn];
    if (enabled == nil) {
        return YES;
    }
 
    return [enabled boolValue];
}


#pragma mark -
#pragma mark PopUp

+ (BOOL)isPopUpEnabled {
    return YES;
}


+ (void)playNotificationSoundAndVibrate{
    if([[self class] isSoundEnabled])
	{
        if(audioPlayer == nil){
            //Get the filename of the sound file:
            NSString *path = [[NSBundle mainBundle] pathForResource:@"sound" ofType:@"mp3"];
		
            //Get a URL for the sound file
            NSURL *filePath = [NSURL fileURLWithPath:path];
		
            audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:nil];
            audioPlayer.volume = 1.0;
        }
		[audioPlayer play];
    }
    
    if([[self class] isVibrationEnabled]){
        // vibrate
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

@end
