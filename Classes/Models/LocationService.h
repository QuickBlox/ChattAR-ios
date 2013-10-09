//
//  GeoData.h
//  ChattAR
//
//  Created by Igor Alefirenko on 30/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface LocationService : NSObject <CLLocationManagerDelegate>{
}

@property (nonatomic, strong) CLLocation *myLocation;
@property (nonatomic, strong) CLLocationManager *myLocationManager;

+ (instancetype)shared;

#pragma mark - Update location
- (void)startUpdateLocation;
- (void)stopUpdateLocation;

#pragma mark - Requests
- (CLLocationCoordinate2D)getMyCoorinates;

@end
