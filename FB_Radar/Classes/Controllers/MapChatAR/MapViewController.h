//
//  MapViewController.h
//  Fbmsg
//
//  Created by Igor Khomenko on 3/27/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapMarkerView.h"
#import "CustomSwitch.h"

@interface MapViewController : UIViewController <MKMapViewDelegate>{
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) IBOutlet MKMapView *mapView;

- (void)refreshWithNewPoints:(NSArray *)mapPoints;
- (void)addPoints:(NSArray *)mapPoints;
- (void)addPoint:(UserAnnotation *)mapPoint;

- (void)clear;

@end
