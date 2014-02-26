//
//  MapPin.h
//  ChattAR
//
//  Created by Igor Alefirenko on 03/10/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject <MKAnnotation> 

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) QBCOCustomObject *room;

- (id)initWithCoordinates:(CLLocationCoordinate2D)coordinates;

@end
