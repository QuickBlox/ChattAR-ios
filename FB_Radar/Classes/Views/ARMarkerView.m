//
//  ARMarkerView.m
//  MashApp-location_users-ar-ios
//
//  Created by Igor Khomenko on 3/26/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "ARMarkerView.h"

#define markerWidth 114
#define markerHeight 40

@implementation ARMarkerView

@synthesize target;
@synthesize action;
@synthesize userStatus, userPhotoView, distanceLabel, userName, userAnnotation;
@synthesize distance;

- (id)initWithGeoPoint:(UserAnnotation *)_userAnnotation{
    	
	CGRect theFrame = CGRectMake(0, 0, markerWidth, markerHeight);
	
	if ((self = [super initWithFrame:theFrame])) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        // save user annotation
        self.userAnnotation = _userAnnotation;
        
        [self setUserInteractionEnabled:YES];
        
        // bg view for user name & status & photo
        //
        UIImageView *container = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, markerWidth, markerHeight)];
		[container.layer setBorderColor:[[UIColor whiteColor] CGColor]];
		[container.layer setBorderWidth:1.0];
        
		if(![[[DataManager shared].myFriendsAsDictionary allKeys] containsObject:self.userAnnotation.fbUserId])
        {
            [container setImage:[UIImage imageNamed:@"Marker2.png"]];
        }
        else
        {
            [container setImage:[UIImage imageNamed:@"Marker.png"]];
        }
        container.layer.cornerRadius = 2;
        container.clipsToBounds = YES;
        [container setBackgroundColor:[UIColor clearColor]];
        [self addSubview:container];
        [container release];
        
        
        // add user photo 
        //
		userPhotoView = [[AsyncImageView alloc] initWithFrame: CGRectMake(0, 0, 40, 40)];
		[userPhotoView loadImageFromURL:[NSURL URLWithString:_userAnnotation.userPhotoUrl]];
		[container addSubview: userPhotoView];
        [userPhotoView release];
        
        
        // add userName
        //
        userName = [[UILabel alloc] initWithFrame:CGRectMake(42, 0, container.frame.size.width-43, container.frame.size.height/2)];
        [userName setBackgroundColor:[UIColor clearColor]];
        [userName setText:_userAnnotation.userName];
        [userName setFont:[UIFont boldSystemFontOfSize:11]];
        [userName setTextColor:[UIColor whiteColor]];
        [container addSubview:userName];
        [userName release];
        
        
        // add userStatus
        //
        userStatus = [[UILabel alloc] initWithFrame:CGRectMake(42, 20, container.frame.size.width-43, container.frame.size.height/2)];
        [userStatus setFont:[UIFont systemFontOfSize:11]];
        [userStatus setText:[[DataManager shared] messageFromQuote:_userAnnotation.userStatus]];
        [userStatus setBackgroundColor:[UIColor clearColor]];
        [userStatus setTextColor:[UIColor whiteColor]];
        [container addSubview:userStatus];
        [userStatus release];
        
        
        // add arrow
        //
        UIImageView *arrow = [[UIImageView alloc] init];
        [arrow setImage:[UIImage imageNamed:@"Marker_arrow.png"]];
        [arrow setFrame:CGRectMake(53, 40, 10, 8)];
        [self addSubview: arrow];
        [arrow release];
        
        
        // distance
		distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, markerWidth, 10)];
		[distanceLabel setBackgroundColor:[UIColor clearColor]];
		[distanceLabel setTextColor:[UIColor whiteColor]];
        [distanceLabel setFont:[UIFont systemFontOfSize:11]];
		[distanceLabel setTextAlignment:UITextAlignmentCenter];
        [self addSubview:distanceLabel];
        [distanceLabel release];
	}
	
    return self;
}

- (void)updateCoordinate:(CLLocationCoordinate2D)newCoordinate{
    userAnnotation.coordinate = newCoordinate;
}

- (void)updateStatus:(NSString *)newStatus{
    userAnnotation.userStatus = newStatus;
    userStatus.text = newStatus;
}

- (CLLocationDistance) updateDistance:(CLLocation *)newOriginLocation{
    CLLocation *pointLocation = [[CLLocation alloc] initWithLatitude:userAnnotation.coordinate.latitude longitude:userAnnotation.coordinate.longitude];
    CLLocationDistance _distance = [pointLocation distanceFromLocation:newOriginLocation];

    if (_distance > 1000){
        distanceLabel.text = [NSString stringWithFormat:@"%.000f km", _distance/1000];
    }else {
        distanceLabel.text = [NSString stringWithFormat:@"%.000f m", _distance];
    }

    
    distance = _distance;
    
    return _distance;
}

- (double)distanceFrom:(CLLocationCoordinate2D)locationA to:(CLLocationCoordinate2D)locationB{
    double R = 6368500.0; // in meters
    
    double lat1 = locationA.latitude*M_PI/180.0;
    double lon1 = locationA.longitude*M_PI/180.0;
    double lat2 = locationB.latitude*M_PI/180.0;
    double lon2 = locationB.longitude*M_PI/180.0;
    
    return acos(sin(lat1) * sin(lat2) + 
                cos(lat1) * cos(lat2) *
                cos(lon2 - lon1)) * R;
}


// touch action
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if([target respondsToSelector:action]){
        [target performSelector:action withObject:self];
    }
}

- (void)dealloc {
    [userAnnotation release];
    [super dealloc];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"distance=%d", distance];
}

@end
