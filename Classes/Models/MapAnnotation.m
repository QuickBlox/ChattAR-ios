//
//  MapPin.m
//  ChattAR
//
//  Created by Igor Alefirenko on 03/10/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation

- (id)initWithCoordinates:(CLLocationCoordinate2D)coordinates{
    self = [super init];
    if (self) {
        self.coordinate = coordinates;
    }
    return self;
}

@end
