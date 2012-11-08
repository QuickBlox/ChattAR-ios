//
//  MapViewController.m
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 3/27/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
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
    
    //add rotation gesture 
    UIGestureRecognizer *rotationGestureRecognizer;
    rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(spin:)];
    [rotationGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:rotationGestureRecognizer];
    [rotationGestureRecognizer release];
    
    
    count     = 0;
    lastCount = 0;
    
    annotationsViewCount = 0;
    
    //add frames for change zoom map
    mapFrameZoomOut.size.width  = 320.0f;
    mapFrameZoomOut.size.height = 387.0f;
    
    mapFrameZoomOut.origin.y = 0;
    mapFrameZoomOut.origin.x = 0;
    
    mapFrameZoomIn.size.width  = 503.0f;
    mapFrameZoomIn.size.height = 503.0f;
    
    mapFrameZoomIn.origin.x = -91.5f;
    mapFrameZoomIn.origin.y = -58.0f;
    
    if(IS_HEIGHT_GTE_568){
        mapFrameZoomOut.size.height = 475.0f;
        
        mapFrameZoomIn.size.height  = 573.0f;
        mapFrameZoomIn.size.width   = 573.0f;
        
        mapFrameZoomIn.origin.x = -126.5f;
        mapFrameZoomIn.origin.y = -49.0f;
    }
    
    //add compass image
    compass = [[UIImageView alloc] init];
    
    CGRect compassFrame;
    compassFrame.size.height = 40;
    compassFrame.size.width  = 40;
    
    compassFrame.origin.x = 260;
    compassFrame.origin.y = 15;
    
    [self.compass setImage:[UIImage imageNamed:@"compass.png" ]];
    [self.compass setAlpha:0.0f];
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
        [self rotateAnnotations:(-count)];
    }
}

- (void)rotateAnnotations:(CGFloat) angle{
    [[self.mapView annotations] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MKAnnotationView * view = [self.mapView viewForAnnotation:obj];
        
            [view setTransform:CGAffineTransformMakeRotation(angle)];
        
        }];
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

    if (IS_IOS_6) {
        [marker setTransform:CGAffineTransformMakeRotation(0.001)];
        if(count){
            [marker setTransform:CGAffineTransformMakeRotation(-count)];
        }
    } else{
        annotationsViewCount++;
        if(annotationsViewCount == [self.mapView.annotations count]){
            annotationsViewCount = 0;
            [self rotateAnnotations:(-count)];
            double delayInSeconds = 0.00001;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
                [marker setTransform:CGAffineTransformMakeRotation(-count)];
            });
        }
    }
    
    
	return marker;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    float longitudeDeltaZoomOut = 255.0f;
    float longitudeDeltaZoomIn  = 353.671875f;
    
    float zoomOun = 0.38f;
    float zoomIn  = 0.43f;
    
    if(IS_HEIGHT_GTE_568){
        longitudeDeltaZoomOut = 112.5;
        longitudeDeltaZoomIn  = 180.0f;
    }
    
    if( ((self.mapView.region.span.longitudeDelta / longitudeDeltaZoomOut) < zoomOun) && !canRotate ){
        
        [self.mapView setFrame:mapFrameZoomIn];
        
        canRotate = YES;
        
        [self.compass setAlpha:1.0f];
        
    }
    
    // rotate map to init state
    if(((self.mapView.region.span.longitudeDelta / longitudeDeltaZoomIn) > zoomIn) && canRotate){
        
        canRotate = NO;
        [self.compass setAlpha:0.0f];
        
        count = 0;
        
        [self performSelector:@selector(setZoomOut) withObject:nil afterDelay:1];
        
        [UIView animateWithDuration:0.3f
                         animations:^{
                             [self.mapView setTransform:CGAffineTransformMakeRotation(count)];
                             [self.compass setTransform:CGAffineTransformMakeRotation(count)];
                             [self rotateAnnotations:(count)];
                         }
         ];
    }
}

- (void)setZoomOut{
    [self.mapView setFrame:mapFrameZoomOut];
}


#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
}

@end
