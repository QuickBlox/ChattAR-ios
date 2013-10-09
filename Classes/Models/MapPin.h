//
//  MapPin.h
//  ChattAR
//
//  Created by Igor Alefirenko on 03/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPin : NSObject <MKAnnotation> {
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;

- (id)initWithCoordinates:(CLLocationCoordinate2D)coordinates;

@end
