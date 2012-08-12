//
//  ARMarkerView.h
//  MashApp-location_users-ar-ios
//
//  Created by Igor Khomenko on 3/26/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "UserAnnotation.h"
#import "AsyncImageView.h"

@interface ARMarkerView : UIView{
}
@property (nonatomic, assign) AsyncImageView *userPhotoView;
@property (nonatomic, assign) UILabel *userName;
@property (nonatomic, assign) UILabel *userStatus;
@property (nonatomic, retain) UserAnnotation *userAnnotation;
@property (nonatomic, assign) UILabel *distanceLabel;
@property (nonatomic, assign) int distance;

@property (assign, nonatomic) id target;
@property SEL action;

- (id)initWithGeoPoint:(UserAnnotation *)_userAnnotation;
- (CLLocationDistance) updateDistance:(CLLocation *)newOriginLocation;
- (void)updateStatus:(NSString *)newStatus;
- (void)updateCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end