//
//  Utilites.h
//  ChattAR
//
//  Created by Igor Alefirenko on 26/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilites : NSObject

@property (nonatomic, assign) BOOL userLoggedIn;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

+ (instancetype)shared;
- (NSString *)distanceFormatter:(CLLocationDistance)distance;
- (void)checkAndPutStatusBarColor;
+ (BOOL)deviceSupportsAR;

// Splash appearence options:
- (BOOL)isUserLoggedIn;
- (void)setUserLogIn;

@end
