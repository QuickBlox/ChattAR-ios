//
//  Utilites.m
//  ChattAR
//
//  Created by Igor Alefirenko on 26/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "Utilites.h"

@implementation Utilites

+ (instancetype)shared {
    static Utilites *defaultKit = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultKit = [[self alloc] init];
    });
    return defaultKit;
}

- (id)init {
    if (self = [super init]) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"HH:mm"];
        [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    }
    return self;
}


#pragma mark -
#pragma mark Converter

- (NSString *)distanceFormatter:(CLLocationDistance)distance{
    NSString *formatedDistance;
    NSInteger dist = round(distance);
    if (distance <=999) {
        formatedDistance = [NSString stringWithFormat:@"%d m", dist];
    } else{
        dist = round(dist) / 1000;
        formatedDistance = [NSString stringWithFormat:@"%d km",dist];
    }
    return formatedDistance;
}


#pragma mark -
#pragma mark Status Bar

- (void)checkAndPutStatusBarColor{
    if ([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleDefault) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
}

@end
