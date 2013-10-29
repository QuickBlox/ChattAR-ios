//
//  GeoData.m
//  ChattAR
//
//  Created by Igor Alefirenko on 30/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "LocationService.h"

@implementation LocationService

+(instancetype)shared{
    static LocationService *defaultData = nil;
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
        self.myLocationManager.delegate = self;
        [_myLocationManager setDistanceFilter:1];
        self.myLocationManager.headingFilter = kCLHeadingFilterNone;
        [_myLocationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    return self;
}


#pragma mark - Update location

-(void)startUpdateLocation {
    [self.myLocationManager startUpdatingLocation];
    [self.myLocationManager startUpdatingHeading];
}

-(void)stopUpdateLocation {
    [self.myLocationManager stopUpdatingLocation];
    [self.myLocationManager stopUpdatingHeading];
}


#pragma mark - Requests
-(CLLocationCoordinate2D)getMyCoorinates {
    return _myLocation.coordinate;
}


#pragma mark -
#pragma mark CoreLocationDelegate

- (void) locationManager:(CLLocationManager *)manager
        didFailWithError:(NSError *)error{
    NSLog(@"Error: %@", error);
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    _myLocation = [locations lastObject];
}

@end
