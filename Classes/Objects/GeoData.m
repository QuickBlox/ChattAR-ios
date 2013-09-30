//
//  GeoData.m
//  ChattAR
//
//  Created by Igor Alefirenko on 30/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "GeoData.h"

@implementation GeoData
@synthesize myLocation = _myLocation;
@synthesize myLocationManager = _myLocationManager;

+(GeoData *)getData{
    static GeoData *defaultData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultData = [[self alloc] init];
    });
    return defaultData;
}

-(id)init{
    self = [super init];
    if (self) {
        self.myLocationManager = [[CLLocationManager alloc] init];
        [myLocationManager setDelegate:self];
        [myLocationManager setDistanceFilter:1];
        [myLocationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    return self;
}


#pragma mark - Update location

-(void)startUpdateLocation {
    [self.myLocationManager startUpdatingLocation];
}

-(void)stopUpdateLocation {
    [self.myLocationManager stopUpdatingLocation];
}


#pragma mark - Requests
-(CLLocationCoordinate2D)getMyCoorinates {
    return myLocation.coordinate;
}


#pragma mark -
#pragma mark CoreLocationDelegate

- (void) locationManager:(CLLocationManager *)manager
        didFailWithError:(NSError *)error{
    NSLog(@"Error: %@", error);
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    myLocation = [locations lastObject];
}

@end
