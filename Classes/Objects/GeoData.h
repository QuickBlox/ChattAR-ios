//
//  GeoData.h
//  ChattAR
//
//  Created by Igor Alefirenko on 30/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface GeoData : NSObject <CLLocationManagerDelegate>{
    CLLocationManager *myLocationManager;
    CLLocation *myLocation;
}

@property (nonatomic, strong) CLLocation *myLocation;
@property (nonatomic, strong) CLLocationManager *myLocationManager;

+(GeoData *)getData;

#pragma mark - Update location
-(void)startUpdateLocation;
-(void)stopUpdateLocation;

#pragma mark - Requests
-(CLLocationCoordinate2D)getMyCoorinates;

@end
