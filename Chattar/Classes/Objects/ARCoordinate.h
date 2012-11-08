//
//  ARCoordinate.h
//  ChattAR for facebook
//
//  Created by QuickBlox developers on 3/26/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * (180.0/M_PI))

@class ARCoordinate;

@interface ARCoordinate : NSObject {
	double radialDistance;
	double inclination;
	double azimuth;
	
	NSString *title;
	NSString *subtitle;
}
@property (nonatomic, retain)	NSString *title;
@property (nonatomic, copy)		NSString *subtitle;
@property (nonatomic) double	radialDistance;
@property (nonatomic) double	inclination;
@property (nonatomic) double	azimuth;

+ (ARCoordinate *)coordinateWithRadialDistance:(double)newRadialDistance inclination:(double)newInclination azimuth:(double)newAzimuth;

- (NSUInteger) hash;
- (BOOL) isEqual:(id)other;
- (BOOL) isEqualToCoordinate:(ARCoordinate *) otherCoordinate;

@end
