//
//  AugmentedRealityController.m
//  ChattAR
//
//  Created by QuickBlox developers on 3/26/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

#import "ARViewController.h"
#import "ARCoordinate.h"
#import "ARGeoCoordinate.h"
#import "ARMarkerView.h"
#import "ChatRoomViewController.h"
#import "LocationService.h"
#import "ChatRoomStorage.h"
#import "CaptureSessionService.h"

@interface ARViewController () <CLLocationManagerDelegate>

@property (nonatomic, assign) BOOL scaleViewsBasedOnDistance;
@property (nonatomic, assign) BOOL transparenViewsBasedOnDistance;
@property (nonatomic, assign) BOOL rotateViewsBasedOnPerspective;

@property (nonatomic, assign) double maximumScaleDistance;
@property (nonatomic, assign) double minimumScaleFactor;
@property (nonatomic, assign) double maximumRotationAngle;
@property (nonatomic, assign) double degreeRange;
@property (nonatomic, assign) double latestHeading;
@property (nonatomic, assign) float  viewAngle;

@property (nonatomic, strong) CMMotionManager         *motionManager;
@property (nonatomic, strong) ARCoordinate            *centerCoordinate;
@property (nonatomic, strong) CLLocation              *centerLocation;
@property (nonatomic, strong) UIImageView             *displayView;

@property (nonatomic, strong) UISlider* distanceSlider;
@property (nonatomic, strong) UILabel* distanceLabel;

@property (strong) NSMutableArray *coordinates;
@property (strong) NSMutableArray *coordinateViews;

@property (nonatomic, assign) int switchedDistance;
@property (nonatomic, strong) NSArray *sliderNumbers;

@end


@implementation ARViewController

#pragma mark
#pragma mark Init

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Create background view
    _displayView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen]  bounds]];
    [_displayView setUserInteractionEnabled:YES];
    _displayView.clipsToBounds = YES;
    [_displayView setBackgroundColor:[UIColor clearColor]];
    self.view = _displayView;
    
    [self configureOptions];
    
    // display Slider and label:
    [self configureDistanceSlider];
    [self configureDistanceLabel];
    
    
    // set default distance
    NSUInteger index = _distanceSlider.value;
    _switchedDistance = [[_sliderNumbers objectAtIndex:index] intValue]; // <-- This is the number you want.
    
    [Flurry logEvent:kFlurryEventARScreenWasOpened];
	CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * 0.5);
	_distanceSlider.transform = trans;
	self.centerLocation = [[LocationService shared] myLocation];
    
    [self refreshWithNewRooms:[[ChatRoomStorage shared] allLocalRooms]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self displayAR];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self dismissAR];
}

- (void)dealloc {
    [LocationService shared].myLocationManager.delegate = [LocationService shared];
}

- (void)configureOptions
{
	_coordinates = [[NSMutableArray alloc] init];
	_coordinateViews = [[NSMutableArray alloc] init];
	_latestHeading	= -1.0f;
    
	self.maximumScaleDistance = 1.3;
	self.minimumScaleFactor = 0.3;
    
	self.scaleViewsBasedOnDistance = YES;
    self.transparenViewsBasedOnDistance = YES;
	self.rotateViewsBasedOnPerspective = NO;
    
	self.maximumRotationAngle = M_PI / 6.0;
    self.degreeRange = _displayView.frame.size.width / 12;
    
    _sliderNumbers = @[@1000, @5000, @10000, @50000, @150000, @500000, @1000000, @(maxARDistance)];
}

- (void)configureDistanceSlider
{
    _distanceSlider = [[UISlider alloc] init];
	[_distanceSlider setFrame:CGRectMake(-127, 160, 300, 30)];
	[_distanceSlider addTarget:self action:@selector(distanceDidChanged:) forControlEvents:UIControlEventValueChanged];
	_distanceSlider.minimumValue =  0;
	_distanceSlider.maximumValue = [_sliderNumbers count]-1;
    _distanceSlider.continuous = YES;
	[_distanceSlider setValue:2 animated:NO];
    
    if(IS_HEIGHT_GTE_568){
        CGRect distanceSliderFrame = self.distanceSlider.frame;
        distanceSliderFrame.origin.y += 44;
        [self.distanceSlider setFrame:distanceSliderFrame];
    }
    [self.displayView addSubview:_distanceSlider];
}

- (void)configureDistanceLabel
{
    _distanceLabel = [[UILabel alloc] init];
    [_distanceLabel setFrame:CGRectMake(19, 335, 100, 20)];
    [_distanceLabel setBackgroundColor:[UIColor clearColor]];
    [_distanceLabel setFont:[UIFont systemFontOfSize:12]];
    [_distanceLabel setTextColor:[UIColor whiteColor]];
    _distanceLabel.text = [NSString stringWithFormat:@"%d km", [[_sliderNumbers objectAtIndex:_distanceSlider.value] intValue]/1000];
    
    if(IS_HEIGHT_GTE_568){
        CGRect distanceLabelFrame = self.distanceLabel.frame;
        distanceLabelFrame.origin.y += 44;
        [self.distanceLabel setFrame:distanceLabelFrame];
    }
    [self.displayView addSubview:_distanceLabel];
}

- (void)distanceDidChanged:(UISlider *)slider
{
    NSUInteger index = slider.value;
    [slider setValue:index animated:NO];
    
    // set dist
    _switchedDistance = [[_sliderNumbers objectAtIndex:index] intValue]; // <-- This is the number you want.
    
    _distanceLabel.text = [NSString stringWithFormat:@"%d km", _switchedDistance/1000];
}

- (void)setCenterLocation:(CLLocation *)newLocation {
	_centerLocation = newLocation;
	
    // update markers positions
    [self updateMarkersPositionsForCenterLocation:newLocation];
}

// touch on marker
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *lastTouch = [touches anyObject];
    
    if([lastTouch.view isKindOfClass:ARMarkerView.class]){
        ARMarkerView *marker = (ARMarkerView *)lastTouch.view;
        [marker.target performSelector:marker.action withObject:marker];
        return;
    }
}

// This is needed to start showing the Camera of the Augemented Reality Toolkit.
- (void)displayAR {
    
    // show Camera capture preview
    CGRect layerRect = [[self.displayView layer] bounds];
    [[CaptureSessionService shared].prewiewLayer setBounds:layerRect];
    [[CaptureSessionService shared].prewiewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
    [self.displayView.layer addSublayer:[CaptureSessionService shared].prewiewLayer];
    
	[self startListening];
}

- (void)dismissAR {
    [[CaptureSessionService shared].prewiewLayer removeFromSuperlayer];
}

/*
 Return view for new user annotation
 */
- (UIView *)viewForAnnotation:(QBCOCustomObject *)roomAnnotation {
    ARMarkerView *marker = [[ARMarkerView alloc] initWithGeoPoint:roomAnnotation];
    marker.target = self;
    marker.action = @selector(touchOnMarker:);
    return marker;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kARToChatSegueIdentifier]){
        // passcurrent room to Chat Room controller
        ((ChatRoomViewController *)segue.destinationViewController).controllerName = @"AR";
        ((ChatRoomViewController *)segue.destinationViewController).currentChatRoom = sender;
    }
}

- (void)startListening {
    // Core Location:
    [[LocationService shared].myLocationManager setDelegate:self];
    
    self.motionManager = [[CMMotionManager alloc] init];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    if (self.motionManager.accelerometerAvailable) {
        self.motionManager.accelerometerUpdateInterval = 1.0/10.0;
        
        __weak ARViewController *this = self;
        [self.motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
             if(error) {
                 [this.motionManager stopAccelerometerUpdates];
             } else {
                 _viewAngle = atan2(accelerometerData.acceleration.y, accelerometerData.acceleration.z);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [this updateCenterCoordinate];
                 });
             }
        }];
    }
	
	if (self.centerCoordinate == nil){
		self.centerCoordinate = [ARCoordinate coordinateWithRadialDistance:1.0 inclination:0 azimuth:0];
    }
}

- (void)touchOnMarker:(ARMarkerView *)marker {
    QBCOCustomObject *room = [marker currentRoom];
    [self performSegueWithIdentifier:kARToChatSegueIdentifier sender:room];
}


#pragma mark
#pragma mark Points management

- (void)addPoints:(NSArray *)newRooms {
    // add new
    if([newRooms count] > 0){
        for(QBCOCustomObject *room in newRooms){
            // add user annotation
			if ([room isKindOfClass:[QBCOCustomObject class]]){
				[self addPoint:room];
			}
        }
    }
    
    // update markers positions
    [self updateMarkersPositionsForCenterLocation:_centerLocation];
}

- (void)addPoint:(QBCOCustomObject *)roomAnnotation {
    
    // add marker
    // get view for annotation
    UIView *markerView = [self viewForAnnotation:roomAnnotation];
    
    // create marker location
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[roomAnnotation.fields[kLatitude] doubleValue]
                                                      longitude:[roomAnnotation.fields[kLongitude] doubleValue]];
    
    // create AR coordinate
    ARCoordinate *coordinateForUser = [ARGeoCoordinate coordinateWithLocation:location
                                                                locationTitle:roomAnnotation.fields[kName]];
    
	[self addCoordinate:coordinateForUser augmentedView:markerView animated:NO];
}

- (void)refreshWithNewRooms:(NSArray *)newRooms {
	// remove old
	for (UIView* view in _displayView.subviews){
		if (view == _distanceLabel || view == _distanceSlider){
			continue;
		}
        
		[view removeFromSuperview];
	}
	[self.coordinates removeAllObjects];
	[self.coordinateViews removeAllObjects];
	
    
    // add new
    [self addPoints:newRooms];
}


#pragma mark
#pragma mark Coordinates management

- (void)addCoordinate:(ARCoordinate *)coordinate augmentedView:(UIView *)agView animated:(BOOL)animated {
	[self.coordinates addObject:coordinate];
	
	if (coordinate.radialDistance > self.maximumScaleDistance) {
		self.maximumScaleDistance = coordinate.radialDistance;
    }
	
	[self.coordinateViews addObject:agView];
}

- (void)removeCoordinate:(ARCoordinate *)coordinate {
	[self removeCoordinate:coordinate animated:YES];
}

- (void)removeCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated {
	NSUInteger indexToRemove = [self.coordinates indexOfObject:coordinate];
    [self.coordinates	 removeObjectAtIndex:indexToRemove];
    [self.coordinateViews removeObjectAtIndex:indexToRemove];
}

- (void)removeCoordinates:(NSArray *)coordinateArray {
	for (ARCoordinate *coordinateToRemove in coordinateArray) {
		[self removeCoordinate:coordinateToRemove animated:NO];
	}
}


#pragma mark
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	_latestHeading = degreesToRadian(newHeading.magneticHeading);
	[self updateCenterCoordinate];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.centerLocation = newLocation;
    });
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	
}


#pragma mark
#pragma mark Private methods

// called when updating acceleration or locationHeading 
- (void)updateCenterCoordinate {
	self.centerCoordinate.azimuth = _latestHeading;
    
	[self updateMarkersPositions];
}

// called by the two next methods 
- (double)findDeltaOfRadianCenter:(double*)centerAzimuth coordinateAzimuth:(double)pointAzimuth betweenNorth:(BOOL*)isBetweenNorth {
    
	if (*centerAzimuth < 0.0) 
		*centerAzimuth = (M_PI * 2.0) + *centerAzimuth;
	
	if (*centerAzimuth > (M_PI * 2.0)) 
		*centerAzimuth = *centerAzimuth - (M_PI * 2.0);
	
	double deltaAzimuth = ABS(pointAzimuth - *centerAzimuth);
	*isBetweenNorth		= NO;
    
	// If values are on either side of the Azimuth of North we need to adjust it.  Only check the degree range
	if (*centerAzimuth < degreesToRadian(self.degreeRange) && pointAzimuth > degreesToRadian(360-self.degreeRange)) {
		deltaAzimuth	= (*centerAzimuth + ((M_PI * 2.0) - pointAzimuth));
		*isBetweenNorth = YES;
	}
	else if (pointAzimuth < degreesToRadian(self.degreeRange) && *centerAzimuth > degreesToRadian(360-self.degreeRange)) {
		deltaAzimuth	= (pointAzimuth + ((M_PI * 2.0) - *centerAzimuth));
		*isBetweenNorth = YES;
	}
    
	return deltaAzimuth;
}

// called by updateLocations 
- (CGPoint)pointInView:(UIView *)realityView withView:(UIView *)viewToDraw forCoordinate:(ARCoordinate *)coordinate {	
	
	CGPoint point;
	CGRect realityBounds	= realityView.bounds;
	double currentAzimuth	= self.centerCoordinate.azimuth;
	double pointAzimuth		= coordinate.azimuth;
	BOOL isBetweenNorth		= NO;
	double deltaAzimuth		= [self findDeltaOfRadianCenter: &currentAzimuth coordinateAzimuth:pointAzimuth betweenNorth:&isBetweenNorth];
	
	if ((pointAzimuth > currentAzimuth && !isBetweenNorth) || (currentAzimuth > degreesToRadian(360-self.degreeRange) && pointAzimuth < degreesToRadian(self.degreeRange)))
		point.x = (realityBounds.size.width / 2) + ((deltaAzimuth / degreesToRadian(1)) * 12);  // Right side of Azimuth
	else
		point.x = (realityBounds.size.width / 2) - ((deltaAzimuth / degreesToRadian(1)) * 12);	// Left side of Azimuth
	
	point.y = (realityBounds.size.height / 2) + (radianToDegrees(M_PI_2 + _viewAngle)  * 2.0);
	
	return point;
}

// called by updateLocations 
- (BOOL)viewportContainsView:(UIView *)viewToDraw  forCoordinate:(ARCoordinate *)coordinate {    
	double currentAzimuth = self.centerCoordinate.azimuth;
	double pointAzimuth	  = coordinate.azimuth;
	BOOL isBetweenNorth	  = NO;
	double deltaAzimuth	  = [self findDeltaOfRadianCenter: &currentAzimuth coordinateAzimuth:pointAzimuth betweenNorth:&isBetweenNorth];
	BOOL result			  = NO;
	
	if (deltaAzimuth <= degreesToRadian(self.degreeRange))
		result = YES;
    
	return result;
}

- (void)updateMarkersPositionsForCenterLocation:(CLLocation *)__centerLocation
{
    if([self.coordinates count] == 0){
        return;
    }

    [self.coordinates enumerateObjectsUsingBlock:^(ARGeoCoordinate *geoLocation, NSUInteger idx, BOOL *stop) {
        if ([geoLocation isKindOfClass:[ARGeoCoordinate class]]) {
            [geoLocation calibrateUsingOrigin:__centerLocation];
            
            if (geoLocation.radialDistance > self.maximumScaleDistance) {
                self.maximumScaleDistance = geoLocation.radialDistance;
            }
        }
        
        // update distance
        ARMarkerView *marker = [self.coordinateViews objectAtIndex:idx];
        [marker updateDistance:__centerLocation];
    }];

    // sort markers by distance
    int i,j;
    UIView *temp;
    int n = [self.coordinateViews count];
    for (i=0; i<n-1; i++) {
        for (j=0; j<n-1-i; j++) {
            if ([[self.coordinateViews objectAtIndex:j] getDistance] > [[self.coordinateViews objectAtIndex:j+1] getDistance]) {
                temp = [self.coordinateViews objectAtIndex:j];
                [self.coordinateViews replaceObjectAtIndex:j withObject:[self.coordinateViews objectAtIndex:j+1]];
                [self.coordinateViews replaceObjectAtIndex:j+1 withObject:temp];
            }
        }
    }
}

- (void)updateMarkersPositions {
	
	if (!self.coordinateViews || [self.coordinateViews count] == 0) {
		return;
    }
	
	int index			= 0;
	int totalDisplayed	= 0;
	
    int maxShowedMarkerDistance = 0;
    int minShowedMarkerDistance = 100000000;
    int count = 0;

    
	for (ARCoordinate *item in self.coordinates) {
		
		ARMarkerView *viewToDraw = [self.coordinateViews objectAtIndex:index];

		if ([self viewportContainsView:viewToDraw forCoordinate:item] && (viewToDraw.distance < _switchedDistance)) {
			
            // mraker location
			CGPoint locCenter = [self pointInView:self.displayView withView:viewToDraw forCoordinate:item];
			CGFloat scaleFactor = 1.0;
			
			float width	 = viewToDraw.bounds.size.width  * scaleFactor;
			float height = viewToDraw.bounds.size.height * scaleFactor;
			
            int offset = totalDisplayed%2 ? totalDisplayed*25 : -totalDisplayed*25;
			viewToDraw.frame = CGRectMake(locCenter.x - width / 2.0, locCenter.y - (height / 2.0) + offset, width, height);
            
			totalDisplayed++;
            
			//if we don't have a superview, set it up.
			if (!([viewToDraw superview])) {
				[self.view addSubview:viewToDraw];
				//[self.view sendSubviewToBack:viewToDraw];
			}
            
            // save max distance
            if(viewToDraw.distance > maxShowedMarkerDistance){
                maxShowedMarkerDistance = viewToDraw.distance;
            }
            if(viewToDraw.distance < minShowedMarkerDistance){
                minShowedMarkerDistance = viewToDraw.distance;
            }
            
            ++count;
            
        } else{ 
			[viewToDraw removeFromSuperview];
            viewToDraw = nil;
        }
		
		index++;
	}
    
    // Set Alpha & Size based on distance
    if([self scaleViewsBasedOnDistance] || [self transparenViewsBasedOnDistance]){

        float scaledChunkWidth = ((maxShowedMarkerDistance-minShowedMarkerDistance)/1000.f)/countOfScaledChunks;
        
        int i = 0;
        for (ARMarkerView *viewToDraw in self.displayView.subviews) {
            if(![viewToDraw isKindOfClass:ARMarkerView.class]){
                continue;
            }
     
            ++i;
            
            CATransform3D transform = CATransform3DIdentity;
            
			CGFloat scaleFactor = 1.0;
            
            // scale view based on distance
            if ([self scaleViewsBasedOnDistance]) {

                int numberOfChunk = ceil(((viewToDraw.distance-minShowedMarkerDistance)/1000.f)/scaledChunkWidth);

                scaleFactor = 1.0 - numberOfChunk*scaleStep();

                if(scaleFactor > 1){
                    scaleFactor = 1.0;
                }else if (scaleFactor < minARMarkerScale){
                    scaleFactor = minARMarkerScale;
                }

                transform = CATransform3DScale(transform, scaleFactor, scaleFactor, scaleFactor);
                viewToDraw.layer.transform = transform;
            }
            
            // set alpha
            if([self transparenViewsBasedOnDistance]){
                int numberOfChunk = ceil(((viewToDraw.distance-minShowedMarkerDistance)/1000.f)/scaledChunkWidth);
                
                float alpha = 1.0 - numberOfChunk*alphaStep();
                if(alpha > 1){
                    alpha = 1.0;
                }else if (alpha < minARMarkerAlpha){
                    alpha = minARMarkerAlpha;
                }
                viewToDraw.alpha = alpha;
            }
        }
    }
    
    [self.view bringSubviewToFront:_distanceSlider];
    [self.view bringSubviewToFront:_distanceLabel];
}

@end
