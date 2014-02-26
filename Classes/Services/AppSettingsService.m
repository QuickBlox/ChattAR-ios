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

static NSString *kRemoteSettings = @"kRemoteSettings";
static NSString *kLocalLimit = @"local_limit";

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
        [self registerDefaultsFromSettingsBundle];
        self.soundEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSoundEnabled];
        self.vibrationEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kVibrationEnabled];
        
        // restore remote app settings
        //
        NSDictionary *remoteSettings = [[NSUserDefaults standardUserDefaults] objectForKey:kRemoteSettings];
        if(remoteSettings != nil){
            _localLimit = [((NSNumber *)remoteSettings[kLocalLimit]) unsignedIntegerValue];
        }else{
            _localLimit = 500; // default value
        }
        
        // download remote app settings
        //
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *remoteSettings = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://s3.amazonaws.com/qbprod/cc2714e5760746c5ae1cd1e99bbb0c8c00"]];
            
            NSDictionary *json = nil;
            if (remoteSettings != nil) {
                json = [NSJSONSerialization JSONObjectWithData:remoteSettings
                        options:kNilOptions error:nil];
                
                if(json != nil){
                    // save
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [[NSUserDefaults standardUserDefaults] setObject:json forKey:kRemoteSettings];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    });
                }
            }


        });
    }
    return self;
}

- (void)checkSoundAndVibration {
    [self registerDefaultsFromSettingsBundle];
    self.soundEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSoundEnabled];
    self.vibrationEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kVibrationEnabled];
}

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
