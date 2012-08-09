//
//  MapViewController.m
//  Fbmsg
//
//  Created by Igor Khomenko on 3/27/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "MapViewController.h"
#import "MapChatARViewController.h"
#import "UserAnnotation.h"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize mapView;
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [mapView setUserInteractionEnabled:NO];
	mapView.userInteractionEnabled = YES;

	MKCoordinateRegion region;
	//Set Zoom level using Span
	MKCoordinateSpan span;  
	region.center=mapView.region.center;
	span.latitudeDelta=150;
	span.longitudeDelta=150;
	region.span=span;
	[mapView setRegion:region animated:YES];
}

- (void)viewDidUnload
{
    self.mapView = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)pointsUpdated{
	[mapView removeAnnotations:mapView.annotations];
	
	for (UserAnnotation* ann in [((MapChatARViewController *)delegate) mapPoints])
	{
		if ([ann isKindOfClass:[UserAnnotation class]])
		{
			[mapView addAnnotation:ann];
		}
	}
    
    [mapView setUserInteractionEnabled:YES];
}


#pragma mark -
#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id < MKAnnotation >)annotation{
	static NSString* reuseidentifier = @"MapAnnotationIdentifier";
    
    MapMarkerView *marker = (MapMarkerView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:reuseidentifier];
    if(marker == nil){
        marker = [[[MapMarkerView alloc] initWithAnnotation:annotation 
                                    reuseIdentifier:reuseidentifier] autorelease];
    }else{
        [marker updateAnnotation:annotation];
    }
    
    // set touch action
    marker.target = delegate;
    marker.action = @selector(touchOnMarker:);
    
	return marker;
}

@end
