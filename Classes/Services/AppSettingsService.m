//
//  AppSettingsService.m
//  ChattAR
//
//  Created by Igor Alefirenko on 24/12/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "AppSettingsService.h"

static NSString *kSoundEnabled = @"sound_enabled";
static NSString *kVibrationEnabled = @"vibro_enabled";

@implementation AppSettingsService

+ (instancetype)shared {
    static id appSettingsInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appSettingsInstance = [[self alloc] init];
    });
    return appSettingsInstance;
}

- (id)init {
    if (self = [super init]) {
        self.soundEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSoundEnabled];
        self.vibrationEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kVibrationEnabled];
        
        if (_soundEnabled == NO && _vibrationEnabled == NO) {
            [self registerDefaultsFromSettingsBundle];
            
            self.soundEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSoundEnabled];
            self.vibrationEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kVibrationEnabled];
        }
    }
    return self;
}

//- (void)checkSettings {
//    self.soundEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSoundEnabled];
//    self.vibrationEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kVibrationEnabled];
//    NSLog(@"Done");
//}

- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
	
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
	
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
	
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
