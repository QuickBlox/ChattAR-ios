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
@synthesize compass;

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
    
    canRotate = NO;
    
    UIGestureRecognizer *rotationGestureRecognizer;
    rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(spin:)];
    [self.view addGestureRecognizer:rotationGestureRecognizer];
    [rotationGestureRecognizer release];
    
    count     = 0;
    lastCount = 0;
    
    mapFrameZoomOut = self.mapView.frame;
    NSLog(@"%f", self.mapView.frame.size.height);
    NSLog(@"%f", mapFrameZoomOut.size.height);
    
    mapFrameZoomIn.size.width  = 577.0f;
    mapFrameZoomIn.size.height = 577.0f;
    
    mapFrameZoomIn.origin.y -= 49.0f;
    mapFrameZoomIn.origin.x -= 128.5f;
    
    compass = [[UIImageView alloc] init];
    
    CGRect compassFrame;
    compassFrame.size.height = 40;
    compassFrame.size.width  = 40;
    
    compassFrame.origin.x = 260;
    compassFrame.origin.y = 15;
    
    [self.compass setImage:[UIImage imageNamed:@"compass.png" ]];
    [self.compass setFrame:compassFrame];
    [self.view addSubview:compass];
    [compass release];
}

- (void)spin:(UIRotationGestureRecognizer *)gestureRecognizer {
    
    if(canRotate){
        if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
            lastCount = 0;
        }
    
        count += gestureRecognizer.rotation - lastCount;
        lastCount = gestureRecognizer.rotation;
        [self.mapView setTransform:CGAffineTransformMakeRotation(count)];
        [self.compass setTransform:CGAffineTransformMakeRotation(count)];
    
        [[mapView annotations] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MKAnnotationView * view = [mapView viewForAnnotation:obj];
        
            [view setTransform:CGAffineTransformMakeRotation(-count)];
        
        }];
    }
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

- (void)refreshWithNewPoints:(NSArray *)mapPoints{
    // remove old
	[mapView removeAnnotations:mapView.annotations];
	
    // add new
	[self addPoints:mapPoints];
}

- (void)addPoints:(NSArray *)mapPoints{
    // add new
	for (UserAnnotation* ann in mapPoints){
		if ([ann isKindOfClass:[UserAnnotation class]]){
			[mapView addAnnotation:ann];
		}
	}
}

- (void)addPoint:(UserAnnotation *)mapPoint{
    [mapView addAnnotation:mapPoint];
}

- (void)clear{
    [mapView setUserInteractionEnabled:NO];
    [mapView removeAnnotations:mapView.annotations];
	mapView.userInteractionEnabled = YES;
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
        [marker updateAnnotation:(UserAnnotation *)annotation];
    }
    
    // set touch action
    marker.target = delegate;
    marker.action = @selector(touchOnMarker:);
    
	return marker;
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    NSLog(@"zoom = %f", (self.mapView.region.span.longitudeDelta / 255.0f));
    
    NSLog(@"%f", self.mapView.frame.size.width);
    NSLog(@"%f", mapFrameZoomOut.size.width);
    
    if( ((self.mapView.region.span.longitudeDelta / 255.0f) <= 0.5f) && !canRotate ){
        NSLog(@"Zoom in!");
        [self.mapView setFrame:mapFrameZoomIn];
        canRotate = YES;
    }else if(((self.mapView.region.span.longitudeDelta / 255.0f) > 0.5f) && canRotate){
        count = 0;
        
        [UIView animateWithDuration:0.3f
                         animations:^{
                             [self.mapView setTransform:CGAffineTransformMakeRotation(count)];
                             [self.compass setTransform:CGAffineTransformMakeRotation(count)];
                             [[self.mapView annotations] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                 MKAnnotationView * view = [self.mapView viewForAnnotation:obj];
            
                                 [view setTransform:CGAffineTransformMakeRotation(-count)];
            
                             }];
                         }
         ];
        
        [self performSelector:@selector(setZoomOut) withObject:nil afterDelay:3];
    }
}

- (void)setZoomOut{
    [self.mapView setFrame:mapFrameZoomOut];
    canRotate = NO;
}

@end
