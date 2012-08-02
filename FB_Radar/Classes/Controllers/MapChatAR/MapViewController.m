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
@synthesize activityIndicator;
@synthesize allFriendsSwitch;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [activityIndicator startAnimating];
    [mapView setUserInteractionEnabled:NO];
	mapView.userInteractionEnabled = YES;
    
    // add All/Friends switch
    
	allFriendsSwitch = [CustomSwitch customSwitch];
    [allFriendsSwitch setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin)];
    [allFriendsSwitch setCenter:CGPointMake(280, 360)];
    [allFriendsSwitch setValue:worldValue];
    [allFriendsSwitch scaleSwitch:0.9];
    [allFriendsSwitch addTarget:self action:@selector(allFriendsSwitchValueDidChanged:) forControlEvents:UIControlEventValueChanged];
	[allFriendsSwitch setBackgroundColor:[UIColor clearColor]];
	[self.mapView addSubview:allFriendsSwitch];

	MKCoordinateRegion region;
	//Set Zoom level using Span
	MKCoordinateSpan span;  
	region.center=mapView.region.center;
	span.latitudeDelta=150;
	span.longitudeDelta=150;
	region.span=span;
	[mapView setRegion:region animated:TRUE];
    
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[self.mapView bringSubviewToFront:allFriendsSwitch];
}

- (void)viewDidUnload
{
    self.mapView = nil;
    self.activityIndicator = nil;
    self.allFriendsSwitch = nil;
    
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
    
    [activityIndicator stopAnimating];
    [mapView setUserInteractionEnabled:YES];
}

// switch All/Friends
- (void)allFriendsSwitchValueDidChanged:(id)sender{
    [((MapChatARViewController *)delegate) allFriendsSwitchValueDidChanged:sender];
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
