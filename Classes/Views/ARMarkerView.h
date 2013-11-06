//
//  ARMarkerView.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 3/26/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "CAnotation.h"
#import "AsyncImageView.h"

@interface ARMarkerView : UIView

@property (nonatomic, strong) AsyncImageView *userPhotoView;
@property (nonatomic, strong) UILabel *userName;
@property (nonatomic, strong) UILabel *userStatus;
@property (nonatomic, strong) QBCOCustomObject *currentRoom;
@property (nonatomic, assign, getter = getDistance) int distance;

@property (assign, nonatomic) id target;
@property SEL action;

- (id)initWithGeoPoint:(QBCOCustomObject *)room;
- (CLLocationDistance) updateDistance:(CLLocation *)newOriginLocation;


@end