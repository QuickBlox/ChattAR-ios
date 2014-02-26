//
//  MapViewController.h
//  ChattAR
//
//  Created by Igor Alefirenko on 28/08/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SASlideMenuDataSource.h"
#import "MapAnnotationView.h"

@interface MapViewController : UIViewController <QBActionStatusDelegate, MKMapViewDelegate, SASlideMenuDataSource, UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@end
