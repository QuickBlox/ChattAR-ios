//
//  ARGeoCoordinate.h
//  MashApp-location_users-ar-ios
//
//  Created by Igor Khomenko on 3/26/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "ARCoordinate.h"

@interface ARGeoCoordinate : ARCoordinate {
	CLLocation *geoLocation;
}
@property (nonatomic, retain) CLLocation *geoLocation;

+ (ARGeoCoordinate *)coordinateWithLocation:(CLLocation *)location locationTitle:(NSString*) titleOfLocation;
+ (ARGeoCoordinate *)coordinateWithLocation:(CLLocation *)location fromOrigin:(CLLocation *)origin;

- (void)calibrateUsingOrigin:(CLLocation *)origin;

@end
