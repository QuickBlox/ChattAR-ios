//
//  MapPinView.h
//  Fbmsg
//
//  Created by Igor Khomenko on 3/28/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserAnnotation.h"
#import "AsyncImageView.h"

/** Map Pin View class */
@interface MapMarkerView : MKAnnotationView{
    UIView *container;
    UIImage *nameImage;
    UIImage *nameImage2;
}
@property (nonatomic, assign) AsyncImageView *userPhotoView;
@property (nonatomic, assign) UILabel *userName;
@property (nonatomic, assign) UILabel *userStatus;
@property (nonatomic, retain) UserAnnotation *annotation;
@property (nonatomic, retain) UIImageView *userNameBG;

@property (assign, nonatomic) id target;
@property SEL action;

- (void)updateAnnotation:(UserAnnotation *)_annotation;

@end
