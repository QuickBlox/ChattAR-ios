//
//  Utilites.m
//  ChattAR
//
//  Created by Igor Alefirenko on 26/09/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "Utilites.h"

@implementation Utilites

+ (instancetype)shared {
    static id defaultKit = nil;
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
        self.userLoggedIn = NO;
        self.isArNotAvailable = NO;
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


#pragma mark -
#pragma mark Supporting AR

+ (BOOL)deviceSupportsAR {
	BOOL support;
	//Detect camera and compas
	if((![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) || (![CLLocationManager headingAvailable])){
		support = NO;
	} else {
        support = YES;
    }
	return support;
}

- (BOOL)isUserLoggedIn {
    return self.userLoggedIn;
}

- (void)setUserLogIn {
    self.userLoggedIn = YES;
}


#pragma mark -
#pragma mark Escape symbols encoding

+(NSString*)urlencode:(NSString*)unencodedString{
	NSString * encodedString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( NULL, (CFStringRef)unencodedString, NULL, (CFStringRef)@"!-*|~'();:%@&=+$,/\?%#[]{}_^#<>£€¥•", kCFStringEncodingUTF8 ));
	return encodedString;
}

+(NSString*)urldecode:(NSString*)encodedString{
	NSString* decodedString =CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding( NULL, (CFStringRef)encodedString, CFSTR(""), kCFStringEncodingUTF8));
	return decodedString;
}

@end
