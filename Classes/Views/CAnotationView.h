//
//  CAnotationView.h
//  ChattAR
//
//  Created by Igor Alefirenko on 07/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CAnotationView : MKAnnotationView

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, strong) QBCOCustomObject *chatRoom;

- (void)handleAnnotationView;

@end
