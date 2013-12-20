//
//  AugmentedRealityController.m
//  ChattAR
//
//  Created by QuickBlox developers on 3/26/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>

#import "ARViewController.h"
#import "ChatRoomViewController.h"
#import "ARCoordinate.h"
#import "ARGeoCoordinate.h"
#import "ARMarkerView.h"
#import "LocationService.h"
#import "ChatRoomStorage.h"


@interface ARViewController () <UIAccelerometerDelegate, CLLocationManagerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UIActionSheetDelegate>

@property (nonatomic, assign) BOOL scaleViewsBasedOnDistance;
@property (nonatomic, assign) BOOL transparenViewsBasedOnDistance;
@property (nonatomic, assign) BOOL rotateViewsBasedOnPerspective;
@property (nonatomic, assign) BOOL isFirstUpdateLocation;

@property (nonatomic, assign) double maximumScaleDistance;
@property (nonatomic, assign) double minimumScaleFactor;
@property (nonatomic, assign) double maximumRotationAngle;
@property (nonatomic, assign) double degreeRange;
@property (nonatomic, assign) double latestHeading;
@property (nonatomic, assign) float  viewAngle;

@property (nonatomic, strong) UIAccelerometer         *accelerometerManager;
@property (nonatomic, strong) ARCoordinate            *centerCoordinate;
@property (nonatomic, strong) CLLocation              *centerLocation;
@property (nonatomic, strong) UIImageView             *displayView;
@property (nonatomic, assign) UIDeviceOrientation	  currentOrientation;

@property (nonatomic, strong) UISlider* distanceSlider;
@property (nonatomic, strong) UILabel* distanceLabel;

@property (nonatomic, strong) NSMutableArray *coordinates;
@property (retain) NSMutableArray *coordinateViews;


/*!
 @brief	The capture session takes the input from the camera and capture it
 */
@property (nonatomic, retain) AVCaptureSession *captureSession;

- (void) updateCenterCoordinate;
- (void) startListening;
- (double) findDeltaOfRadianCenter:(double*)centerAzimuth coordinateAzimuth:(double)pointAzimuth betweenNorth:(BOOL*) isBetweenNorth;
- (CGPoint) pointInView:(UIView *)realityView withView:(UIView *)viewToDraw forCoordinate:(ARCoordinate *)coordinate;
- (BOOL) viewportContainsView:(UIView *)viewToDraw forCoordinate:(ARCoordinate *)coordinate;

@end

#pragma mark -

@implementation ARViewController{
    int switchedDistance;
    NSArray *sliderNumbers;
}

@synthesize accelerometerManager, displayView, centerCoordinate, scaleViewsBasedOnDistance, isFirstUpdateLocation,transparenViewsBasedOnDistance, rotateViewsBasedOnPerspective, maximumScaleDistance, minimumScaleFactor, maximumRotationAngle, centerLocation, coordinates, currentOrientation, degreeRange;
@synthesize latestHeading, viewAngle, coordinateViews;
@synthesize captureSession;
@synthesize distanceSlider, distanceLabel;


#pragma mark - 
#pragma mark Init & dealloc 

- (void)configureOptions {
	coordinates		= [[NSMutableArray alloc] init];
	coordinateViews	= [[NSMutableArray alloc] init];
	latestHeading	= -1.0f;
    
	self.maximumScaleDistance = 1.3;
	self.minimumScaleFactor = 0.3;
    
    self.isFirstUpdateLocation = YES;
	self.scaleViewsBasedOnDistance = YES;
    self.transparenViewsBasedOnDistance = YES;
	self.rotateViewsBasedOnPerspective = NO;
    
	self.maximumRotationAngle = M_PI / 6.0;
    
    self.currentOrientation = UIDeviceOrientationPortrait; 
    self.degreeRange = displayView.frame.size.width / 12;
    
    sliderNumbers = @[@1000, @5000, @10000, @50000, @150000, @500000, @1000000, @(maxARDistance)];
}

- (void)initDisplay{
    displayView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen]  bounds]];
    [displayView setUserInteractionEnabled:YES];
    displayView.clipsToBounds = YES;
    self.view = displayView;
}

- (void)loadSomeOptions {
    [self initDisplay];
    [self configureOptions];
    
	distanceSlider = [[UISlider alloc] init];
	[distanceSlider setFrame:CGRectMake(-127, 160, 300, 30)];
	[distanceSlider addTarget:self action:@selector(distanceDidChanged:) forControlEvents:UIControlEventValueChanged];
	distanceSlider.minimumValue =  0;
	distanceSlider.maximumValue = [sliderNumbers count]-1;
    distanceSlider.continuous = YES;
    [self.view addSubview:distanceSlider];
	[distanceSlider setValue:2 animated:NO];
    
    distanceLabel = [[UILabel alloc] init];
    [distanceLabel setFrame:CGRectMake(19, 335, 100, 20)];
    [distanceLabel setBackgroundColor:[UIColor clearColor]];
    [distanceLabel setFont:[UIFont systemFontOfSize:12]];
    [distanceLabel setTextColor:[UIColor whiteColor]];
    distanceLabel.text = [NSString stringWithFormat:@"%d km", [[sliderNumbers objectAtIndex:distanceSlider.value] intValue]/1000];
    [self.view addSubview:distanceLabel];
    
    // set dist
    NSUInteger index = distanceSlider.value;
    switchedDistance = [[sliderNumbers objectAtIndex:index] intValue]; // <-- This is the number you want.
    
    if(IS_HEIGHT_GTE_568){
        CGRect distanceSliderFrame = self.distanceSlider.frame;
        distanceSliderFrame.origin.y += 44;
        [self.distanceSlider setFrame:distanceSliderFrame];
        
        CGRect distanceLabelFrame = self.distanceLabel.frame;
        distanceLabelFrame.origin.y += 44;
        [self.distanceLabel setFrame:distanceLabelFrame];
    }
}

- (void)distanceDidChanged:(UISlider *)slider
{
    NSUInteger index = slider.value;
    [slider setValue:index animated:NO];
    
    // set dist
    switchedDistance = [[sliderNumbers objectAtIndex:index] intValue]; // <-- This is the number you want.
    
    distanceLabel.text = [NSString stringWithFormat:@"%d km", switchedDistance/1000];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self loadSomeOptions];
    
    [Flurry logEvent:kFlurryEventARScreenWasOpened];
	CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * 0.5);
	distanceSlider.transform = trans;
	[self.view bringSubviewToFront:distanceSlider];
    [self.view bringSubviewToFront:distanceLabel];
	self.centerLocation = [[LocationService shared] myLocation];
	[displayView setBackgroundColor:[UIColor blackColor]];
    [self displayAR];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    [self refreshWithNewRooms:[[ChatRoomStorage shared] allLocalRooms]];
}

- (void)dealloc {
    self.accelerometerManager.delegate = nil;
    [LocationService shared].myLocationManager.delegate = [LocationService shared];
	
	self.coordinateViews = nil;
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
	
    [self initCapture];
    
	[self startListening];
}



- (void)startListening {
    
    [[LocationService shared].myLocationManager setDelegate:self];
    
	if (!self.accelerometerManager) {
		self.accelerometerManager = [UIAccelerometer sharedAccelerometer];
		self.accelerometerManager.updateInterval = 0.1;
		self.accelerometerManager.delegate = self;
	}
	
	if (!self.centerCoordinate) 
		self.centerCoordinate = [ARCoordinate coordinateWithRadialDistance:1.0 inclination:0 azimuth:0];
}

- (void)refreshWithNewRooms:(NSArray *)newRooms {
	// remove old
	for (UIView* view in displayView.subviews){
		if (view == distanceLabel || view == distanceSlider){
			continue;
		}
        
		[view removeFromSuperview];
	}
	[self.coordinates removeAllObjects];
	[coordinateViews removeAllObjects];
	
    
    // add new
    [self addPoints:newRooms ];
}

- (void)clear {
    [self.coordinates removeAllObjects];
	[coordinateViews removeAllObjects];
}

/*
 Add users' annotations to AR environment
 */
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
    [self updateMarkersPositionsForCenterLocation:centerLocation];
}

/*
 Add user's annotation to AR environment
 */
- (void)addPoint:(QBCOCustomObject *)roomAnnotation {
    
    // add marker
    // get view for annotation
    UIView *markerView = [self viewForAnnotation:roomAnnotation];
    
    // create marker location
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[roomAnnotation.fields objectForKey:kLatitude] doubleValue]
                                                      longitude:[[roomAnnotation.fields objectForKey:kLongitude] doubleValue]];
    
    // create AR coordinate
    ARCoordinate *coordinateForUser = [ARGeoCoordinate coordinateWithLocation:location
                                                                locationTitle:[roomAnnotation.fields objectForKey:kName]];
    
	[self addCoordinate:coordinateForUser augmentedView:markerView animated:NO];
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


#pragma mark -
#pragma mark Marker Action

- (void)touchOnMarker:(ARMarkerView *)marker {
    QBCOCustomObject *room = [marker currentRoom];
    [self performSegueWithIdentifier:kARToChatSegueIdentifier sender:room];
}
/*
 Return view for exist user annotation
 */

/*Add AR coordinate
 */
- (void)addCoordinate:(ARCoordinate *)coordinate augmentedView:(UIView *)agView animated:(BOOL)animated {
	[self.coordinates addObject:coordinate];
	
	if (coordinate.radialDistance > self.maximumScaleDistance) {
		self.maximumScaleDistance = coordinate.radialDistance;
    }
	
	[coordinateViews addObject:agView];
}

/*
 Remove AR coordinate
 */
- (void)removeCoordinate:(ARCoordinate *)coordinate {
	[self removeCoordinate:coordinate animated:YES];
}

- (void)removeCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated {
	NSUInteger indexToRemove = [coordinates indexOfObject:coordinate];
    [self.coordinates	 removeObjectAtIndex:indexToRemove];
    [coordinateViews removeObjectAtIndex:indexToRemove];
}

- (void)removeCoordinates:(NSArray *)coordinateArray {	
	// remove coordinates
	for (ARCoordinate *coordinateToRemove in coordinateArray) {
		[self removeCoordinate:coordinateToRemove animated:NO];
	}
}


#pragma mark - 
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	latestHeading = degreesToRadian(newHeading.magneticHeading);
	[self updateCenterCoordinate];
}


- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	// set new own location
    if (isFirstUpdateLocation){
		self.centerLocation = newLocation;
        self.isFirstUpdateLocation = NO;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	
}


#pragma mark - 
#pragma mark UIAccelerometerDelegate 

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	
	switch (currentOrientation) {
		case UIDeviceOrientationLandscapeLeft:
			viewAngle = atan2(acceleration.x, acceleration.z);
			break;
		case UIDeviceOrientationLandscapeRight:
			viewAngle = atan2(-acceleration.x, acceleration.z);
			break;
		case UIDeviceOrientationPortrait:
			viewAngle = atan2(acceleration.y, acceleration.z);
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			viewAngle = atan2(-acceleration.y, acceleration.z);
			break;	
		default:
			break;
	}
	
	[self updateCenterCoordinate];
}


#pragma mark - 
#pragma mark  Private methods 

// called when updating acceleration or locationHeading 
- (void)updateCenterCoordinate {
	double adjustment = 0;
	
	if (currentOrientation == UIDeviceOrientationLandscapeLeft)
		adjustment = degreesToRadian(270); 
	else if (currentOrientation == UIDeviceOrientationLandscapeRight)
		adjustment = degreesToRadian(90);
	else if (currentOrientation == UIDeviceOrientationPortraitUpsideDown)
		adjustment = degreesToRadian(180);
    
	self.centerCoordinate.azimuth = latestHeading - adjustment;
	[self updateLocations];
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
	
	point.y = (realityBounds.size.height / 2) + (radianToDegrees(M_PI_2 + viewAngle)  * 2.0);
	
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


#pragma mark - 
#pragma mark Properties

- (void)setCenterLocation:(CLLocation *)newLocation {
	centerLocation = newLocation;
	
    // update markers positions
    [self updateMarkersPositionsForCenterLocation:newLocation];
}

- (void)updateMarkersPositionsForCenterLocation:(CLLocation *)_centerLocation 
{
    int index			= 0;

    if([self.coordinates count]){
        for (ARGeoCoordinate *geoLocation in self.coordinates) 
        {
		
            if ([geoLocation isKindOfClass:[ARGeoCoordinate class]]) {
                [geoLocation calibrateUsingOrigin:_centerLocation];
			
                if (geoLocation.radialDistance > self.maximumScaleDistance) {
                    self.maximumScaleDistance = geoLocation.radialDistance;
                }
            }
        
            // update distance
            ARMarkerView *marker = [coordinateViews objectAtIndex:index];
            [marker updateDistance:_centerLocation];
        
            ++index;
        }
    
        //NSLog(@"%f %f",[[self.coordinates lastObject] ] );
    
        // sort markers by distance
        int i,j;
        UIView *temp;
        int n = [coordinateViews count];
        for (i=0; i<n-1; i++) {
            for (j=0; j<n-1-i; j++) {
                if ([[coordinateViews objectAtIndex:j] getDistance] > [[coordinateViews objectAtIndex:j+1] getDistance]) {
                    temp = [coordinateViews objectAtIndex:j];
                    [coordinateViews replaceObjectAtIndex:j withObject:[coordinateViews objectAtIndex:j+1]];
                    [coordinateViews replaceObjectAtIndex:j+1 withObject:temp];
                }
            }
        }
    }
}


#pragma mark -
#pragma mark Public methods 


- (void)updateLocations {
	
	if (!coordinateViews || [coordinateViews count] == 0) {
		return;
    }
	
	int index			= 0;
	int totalDisplayed	= 0;
	
    int maxShowedMarkerDistance = 0;
    int minShowedMarkerDistance = 100000000;
    int count = 0;

    
	for (ARCoordinate *item in self.coordinates) {
		
		ARMarkerView *viewToDraw = [coordinateViews objectAtIndex:index];

		if ([self viewportContainsView:viewToDraw forCoordinate:item] && (viewToDraw.distance < switchedDistance)) {
			
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
				[self.displayView addSubview:viewToDraw];
				[self.displayView sendSubviewToBack:viewToDraw];
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
}


#pragma mark -
#pragma mark Capture

- (void)initCapture {
    
	/*We setup the input*/
	AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput 
										  deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] 
										  error:nil];
	/*We setupt the output*/
	AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
	/*While a frame is processes in -captureOutput:didOutputSampleBuffer:fromConnection: delegate methods no other frames are added in the queue.
	 If you don't want this behaviour set the property to NO */
	captureOutput.alwaysDiscardsLateVideoFrames = YES; 
	/*We specify a minimum duration for each frame (play with this settings to avoid having too many frames waiting
	 in the queue because it can cause memory issues). It is similar to the inverse of the maximum framerate.
	 In this example we set a min frame duration of 1/10 seconds so a maximum framerate of 10fps. We say that
	 we are not able to process more than 10 frames per second.*/
	captureOutput.minFrameDuration = CMTimeMake(1, 15);
	
	/*We create a serial queue to handle the processing of our frames*/
	dispatch_queue_t queue;
	queue = dispatch_queue_create("cameraQueue", NULL);
	[captureOutput setSampleBufferDelegate:self queue:queue];
	dispatch_release(queue);
	// Set the video output to store frame in BGRA (It is supposed to be faster)
	NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey; 
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]; 
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
	[captureOutput setVideoSettings:videoSettings];

	/*And we create a capture session*/
	captureSession = [[AVCaptureSession alloc] init];
	/*We add input and output*/
	[self.captureSession addInput:captureInput];
	[self.captureSession addOutput:captureOutput];
	
	/*We start the capture*/
	[self.captureSession startRunning];
}


#pragma mark -
#pragma mark AVCaptureSession delegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool {

        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        /*Lock the image buffer*/
        CVPixelBufferLockBaseAddress(imageBuffer,0);
        /*Get information about the image*/
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        /*Create a CGImageRef from the CVImageBufferRef*/
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        //	CGContextRotateCTM(newContext, -angleInRadians);
        CGImageRef newImage = CGBitmapContextCreateImage(newContext);
        
        /*We release some components*/
        CGContextRelease(newContext);
        CGColorSpaceRelease(colorSpace);

        /*We display the result on the image view (We need to change the orientation of the image so that the video is displayed correctly).
         Same thing as for the CALayer we are not in the main thread so ...*/
        UIImage *image= [UIImage imageWithCGImage:newImage scale:1 orientation:UIImageOrientationRight];

        /*We relase the CGImageRef*/
        CGImageRelease(newImage);
        
        [displayView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
        
        /*We unlock the  image buffer*/
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    }
}

@end