//
//  MapPinView.m
//  Fbmsg
//
//  Created by Igor Khomenko on 3/28/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "MapMarkerView.h"

#define markerWidth 100
#define markerHeight 55

@implementation MapMarkerView
@synthesize userPhotoView, userName, userStatus, annotation, userNameBG;
@synthesize target, action;

-(id)initWithAnnotation:(id<MKAnnotation>)_annotation reuseIdentifier:(NSString *)reuseIdentifier{
    
    if ((self = [super initWithAnnotation:_annotation reuseIdentifier:reuseIdentifier])) {
        
        self.frame = CGRectMake(0, 0, markerWidth, markerHeight*2);
        
        //self.frame = CGRectMake(0, 0, markerWidth, markerHeight*2);
        // save annotation
        //
        annotation = (UserAnnotation *)[_annotation retain];

        
        // bg view for user name & status & photo
        //
        container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, markerWidth, markerHeight-10)];
        container.layer.cornerRadius = 2;
        container.clipsToBounds = YES;
        [container setBackgroundColor:[UIColor clearColor]];
        [self addSubview:container];
        [container release];
        
        
        // add user photo 
        //
        userPhotoView = [[AsyncImageView alloc] initWithFrame: CGRectMake(0, 0, 45, 45)];
		
		id picture = annotation.userPhotoUrl;
		if ([picture isKindOfClass:[NSString class]])
		{
			[userPhotoView loadImageFromURL:[NSURL URLWithString:annotation.userPhotoUrl]];
		}
		else
		{
			NSDictionary* pic = (NSDictionary*)picture;
			NSString* url = [[pic objectForKey:kData] objectForKey:kUrl];
			[userPhotoView loadImageFromURL:[NSURL URLWithString:url]];
			annotation.userPhotoUrl = url;
		}
        [container addSubview: userPhotoView];
        [userPhotoView release];
        
        
        // add userName
        //
        
        //============================================================================================
        userNameBG = [[UIImageView alloc] init];
        [userNameBG setFrame:CGRectMake(45, 0, 55, 23)];
        
        
        NSArray *friendsIds =  [[DataManager shared].myFriendsAsDictionary allKeys];
        
        if([friendsIds containsObject:[annotation.fbUser objectForKey:kId]]
           || [[DataManager shared].currentFBUserId isEqualToString:[annotation.fbUser objectForKey:kId]]){
            
            [userNameBG setImage:[UIImage imageNamed:@"radarMarkerName@2x.png"]];
        }
        else
        {
            [userNameBG setImage:[UIImage imageNamed:@"radarMarkerName2@2x.png"] ];
        }
        
        [container addSubview: userNameBG];
        [userNameBG release];
        //
        userName = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, userNameBG.frame.size.width-3, userNameBG.frame.size.height)];
        [userName setBackgroundColor:[UIColor clearColor]];
        [userName setText:annotation.userName];
        [userName setFont:[UIFont boldSystemFontOfSize:11]];
        [userName setTextColor:[UIColor whiteColor]];
        [userNameBG addSubview:userName];
        [userName release];
        
        
        // add userStatus
        //
        UIImageView *userStatusBG = [[UIImageView alloc] init];
        [userStatusBG setFrame:CGRectMake(45, 23, 55, 22)];
        [userStatusBG setImage:[UIImage imageNamed:@"radarMarkerStatus@2x.png"]];
        [container addSubview: userStatusBG];
        [userStatusBG release];
        //
        userStatus = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, userStatusBG.frame.size.width-3, userStatusBG.frame.size.height)];
        [userStatus setFont:[UIFont systemFontOfSize:11]];
        [userStatus setText:[[DataManager shared] messageFromQuote:annotation.userStatus]];
        [userStatus setBackgroundColor:[UIColor clearColor]];
        [userStatus setTextColor:[UIColor whiteColor]];
        [userStatusBG addSubview:userStatus];
        [userStatus release];
        
        // add arrow
        //
        UIImageView *arrow = [[UIImageView alloc] init];
        [arrow setImage:[UIImage imageNamed:@"radarMarkerArrow@2x.png"]];
        [arrow setFrame:CGRectMake(45, 45, 10, 8)];
        [self addSubview: arrow];
        [arrow release];

        
        //[self updateContainer:_annotation];
    }
    
    return self;
}

- (void)updateStatus:(NSString *)newStatus{
    annotation.userStatus = newStatus;
    userStatus.text = newStatus;
}

- (void)updateCoordinate:(CLLocationCoordinate2D)newCoordinate{
    annotation.coordinate = newCoordinate;
}

- (void)updateAnnotation:(UserAnnotation *)_annotation{
    
    //[self updateContainer:_annotation];
    [annotation release];
    annotation = [_annotation retain];
    
    NSArray *friendsIds =  [[DataManager shared].myFriendsAsDictionary allKeys];
    
    if([friendsIds containsObject:[annotation.fbUser objectForKey:kId]]
       || [[DataManager shared].currentFBUserId isEqualToString:[annotation.fbUser objectForKey:kId]]){
        
        [userNameBG setImage:[UIImage imageNamed:@"radarMarkerName@2x.png"]];
    }
    else
    {
        [userNameBG setImage:[UIImage imageNamed:@"radarMarkerName2@2x.png"] ];
    }
    
    if ([_annotation.userPhotoUrl isKindOfClass:[NSString class]]){
        [userPhotoView loadImageFromURL:[NSURL URLWithString:_annotation.userPhotoUrl]];
    }else{
        NSDictionary* pic = (NSDictionary*)_annotation.userPhotoUrl;
        NSString* url = [[pic objectForKey:kData] objectForKey:kUrl];
        [userPhotoView loadImageFromURL:[NSURL URLWithString:url]];
    }
    
    [userName setText:_annotation.userName];
    
    [userStatus setText:[[DataManager shared] messageFromQuote:_annotation.userStatus]];
}

// touch action
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [[touches allObjects] objectAtIndex:0];
	CGPoint location = [touch locationInView:self];
	CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2);
	
	if (CGRectContainsPoint(rect, location))
	{
		if([target respondsToSelector:action])
		{
			[target performSelector:action withObject:self];
		}
	}
}

- (void)dealloc
{
    [annotation release];
    [super dealloc];
}

@end
