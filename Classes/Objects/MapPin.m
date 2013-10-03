//
//  MapPin.m
//  ChattAR
//
//  Created by Igor Alefirenko on 03/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "MapPin.h"

@implementation MapPin
@synthesize coordinate=_coordinate, name=_name, description=_description;


- (id)initWithCoordinates:(CLLocationCoordinate2D)coordinates{
    self = [super init];
    if (self) {
        self.coordinate = coordinates;
    }
    return self;
}


@end
