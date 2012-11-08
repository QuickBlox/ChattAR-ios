//
//  MapViewController.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 3/27/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapMarkerView.h"
#import "CustomSwitch.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate>{
    CGFloat count;
    CGFloat lastCount;
    
    CGRect mapFrameZoomOut;
    CGRect mapFrameZoomIn;
    
    BOOL canRotate;
    int annotationsViewCount;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) UIImageView *compass;

- (void)refreshWithNewPoints:(NSArray *)mapPoints;
- (void)addPoints:(NSArray *)mapPoints;
- (void)addPoint:(UserAnnotation *)mapPoint;

- (void)clear;

@end
