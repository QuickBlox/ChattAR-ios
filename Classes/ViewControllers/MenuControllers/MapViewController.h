//
//  MapViewController.h
//  ChattAR
//
//  Created by Igor Alefirenko on 28/08/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CAnotationView.h"

@interface MapViewController : UIViewController <QBActionStatusDelegate, MKMapViewDelegate>
@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@end
