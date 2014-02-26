//
//  MapAnnotationView.h
//  ChattAR
//
//  Created by Igor Alefirenko on 07/10/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "AsyncImageView.h"

@interface MapAnnotationView : MKAnnotationView

@property (nonatomic, strong) AsyncImageView *avatar;
@property (nonatomic, strong) QBCOCustomObject *chatRoom;


- (void)handleAnnotationView;

@end
