//
//  Utilites.h
//  ChattAR
//
//  Created by Igor Alefirenko on 26/09/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBProgressHUD;

@interface Utilites : NSObject

@property (nonatomic, assign) BOOL userLoggedIn;
@property (assign, nonatomic) BOOL isArNotAvailable;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

+ (instancetype)shared;
+ (BOOL)deviceSupportsAR;

- (NSString *)distanceFormatter:(CLLocationDistance)distance;
- (void)checkAndPutStatusBarColor;
- (BOOL)isUserLoggedIn;
- (void)setUserLogIn;

- (NSInteger)yearsFromDate:(NSString *)dateString;

#pragma mark -
#pragma mark Escape symbols encoding

+(NSString*)urlencode:(NSString*)unencodedString;
+(NSString*)urldecode:(NSString*)encodedString;

@end
