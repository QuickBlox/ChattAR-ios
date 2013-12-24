//
//  AppSettingsService.h
//  ChattAR
//
//  Created by Igor Alefirenko on 24/12/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSettingsService : NSObject

@property (nonatomic, assign) BOOL soundEnabled;
@property (nonatomic, assign) BOOL vibrationEnabled;

+ (instancetype)shared;
//- (void)checkSettings;

@end
