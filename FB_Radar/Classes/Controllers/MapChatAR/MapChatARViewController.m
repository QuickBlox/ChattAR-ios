//
//  MapChatARViewController.m
//  Fbmsg
//
//  Created by Alexey on 21.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define mapSearch @"mapSearch"
#define chatSearch @"chatSearch"

#define mapFBUsers @"mapFBUsers"
#define chatFBUsers @"chatFBUsers"

#import "MapChatARViewController.h"
#import "ARManager.h"
#import "ARMarkerView.h"
#import "MessagesViewController.h"
#import "WebViewController.h"


@interface MapChatARViewController ()

@property (nonatomic, retain) CLLocation* myCurrentLocation;

@end

@implementation MapChatARViewController

@synthesize mapViewController, chatViewController, arViewController;
@synthesize segmentControl;
@synthesize mapPoints, chatPoints;
@synthesize userActionSheet, allMapPoints, allCheckins, allChatPoints;
@synthesize selectedUserAnnotation;
@synthesize locationManager, myCurrentLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.title = NSLocalizedString(@"Chat", nil);
		self.tabBarItem.image = [UIImage imageNamed:@"Around_toolbar_icon.png"];
		
		// divice support AR
        if([ARManager deviceSupportsAR]){
            arViewController = [[AugmentedRealityController alloc] initWithViewFrame:CGRectMake(0, 45, 320, 415)];
            arViewController.delegate = self;
        }
        
        mapPoints = [[NSMutableArray alloc] init];
        chatPoints = [[NSMutableArray alloc] init];
		
		myCurrentLocation = [[CLLocation alloc] init];
        
        chatIDs = [[NSMutableArray alloc] init];
        
		self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self; // send loc updates to myself
		
        isInitialized = NO;
        
        
        // logout
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutDone) name:kNotificationLogout object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    self.mapViewController = nil;
    self.chatViewController = nil;
    self.arViewController = nil;
    
    self.selectedUserAnnotation = nil;

    [allChatPoints release];
	[allCheckins release];
	[allMapPoints release];
	
    [mapPoints release];
    [chatPoints release];
    
    [userActionSheet release];
    [chatIDs release];
	
	[locationManager release];
	[myCurrentLocation release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLogout object:nil];
    
    [super dealloc];
}

- (void)logoutDone{
    isInitialized = NO;
    
    [allChatPoints removeAllObjects];
	[allCheckins removeAllObjects];
	[allMapPoints removeAllObjects];
    
    [mapPoints removeAllObjects];
    [chatPoints removeAllObjects];
    
    [chatIDs removeAllObjects];
    
    [updateTimre invalidate];
    [updateTimre release];
    updateTimre = nil;
    
    
    // clean controllers
    [arViewController dissmisAR];
    [mapViewController.mapView removeAnnotations:mapViewController.mapView.annotations];
    [chatViewController.messagesTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[locationManager startUpdatingLocation];
	
    // add segment to title
    if(![self.navigationItem.titleView isKindOfClass:UISegmentedControl.class]){
        NSArray *segments;
        if([ARManager deviceSupportsAR]){
            segments = [NSArray arrayWithObjects:NSLocalizedString(@"Radar", nil), 
                                                    NSLocalizedString(@"Map", nil), 
                                                        NSLocalizedString(@"Chat", nil), nil];
        }else{
            segments = [NSArray arrayWithObjects:NSLocalizedString(@"Map", nil), 
                                                    NSLocalizedString(@"Chat", nil), nil];
        }
        segmentControl = [[UISegmentedControl alloc] initWithItems:segments];
        [segmentControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [segmentControl setFrame:CGRectMake(20, 7, 280, 30)];
        [segmentControl addTarget:self action:@selector(segmentValueDidChanged:) forControlEvents:UIControlEventValueChanged];
		self.navigationItem.titleView = segmentControl;
        [segmentControl release];
    }
	
    mapViewController.delegate = self;
    chatViewController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(!isInitialized){
        initState = 0;
        
        // clean
//        [mapViewController.mapView removeAnnotations:mapViewController.mapView.annotations];
//        [chatViewController.messagesTableView reloadData];
        
        // show wheels
        [arViewController.view addSubview:arViewController.activityIndicator];
        [arViewController.activityIndicator startAnimating];
        [mapViewController.activityIndicator startAnimating];
        [chatViewController.activityIndicator startAnimating];
        //
        
        // get points from QuickBlox
        [self getQBGeodatas];
        
        // show ar/map
        [segmentControl setSelectedSegmentIndex:0];
        [self segmentValueDidChanged:segmentControl];
        
        // get checkins for all friends
        numberOfCheckinsRetrieved = ceil([[DataManager shared].myFriends count]/fmaxRequestsInBatch);
		
        [[FBService shared] friendsCheckinsWithDelegate:self];
        
        isInitialized = YES;
    }    
}

- (void)getQBGeodatas
{
	QBLGeoDataGetRequest *searchMapARPointsRequest = [[QBLGeoDataGetRequest alloc] init];
	searchMapARPointsRequest.lastOnly = YES; // Only last location
	searchMapARPointsRequest.perPage = kGetGeoDataCount; // Pins limit for each page
	searchMapARPointsRequest.sortBy = GeoDataSortByKindCreatedAt;
	[QBLocationService geoDataWithRequest:searchMapARPointsRequest delegate:self context:mapSearch];
	[searchMapARPointsRequest release];
	
	// get points for chat
	QBLGeoDataGetRequest *searchChatMessagesRequest = [[QBLGeoDataGetRequest alloc] init];
	searchChatMessagesRequest.perPage = kGetGeoDataCount; // Pins limit for each page
	searchChatMessagesRequest.status = YES;
	searchChatMessagesRequest.sortBy = GeoDataSortByKindCreatedAt;
	[QBLocationService geoDataWithRequest:searchChatMessagesRequest delegate:self context:chatSearch];
	[searchChatMessagesRequest release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [updateTimre invalidate];
    [updateTimre release];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// get new points from QuickBlox Location
- (void) checkForNewPoints:(NSTimer *) timer{
	QBLGeoDataGetRequest *searchRequest = [[QBLGeoDataGetRequest alloc] init];
	searchRequest.status = YES;
    searchRequest.sortBy = GeoDataSortByKindCreatedAt;
    searchRequest.sortAsc = 1;
    searchRequest.perPage = 15;
    searchRequest.minCreatedAt = [NSDate dateWithTimeIntervalSinceNow:-20];
	[QBLocationService geoDataWithRequest:searchRequest delegate:self];
	[searchRequest release];
}

- (void)segmentValueDidChanged:(id)sender{
    switch (segmentControl.selectedSegmentIndex) {
        // show Radar / Map
        case 0:
            if(segmentControl.numberOfSegments == 2){
                [self showMap];
            }else{
                [self showRadar];
            }
           
            break;
        
        // show Map / Chat
        case 1:
            if(segmentControl.numberOfSegments == 2){
                [self showChat];
            }else{
                [self showMap];
            }
            break;
            
        // Chat
        case 2:
            [self showChat];
                        
            break;
            
        default:
            break;
    }
}

// switch All/Friends
- (void)allFriendsSwitchValueDidChanged:(id)sender{
    int value = (int)[(CustomSwitch *)sender value];
    
    switch (value) {
        // show all users
        case 1:{
			
			if ([arViewController.view superview])
			{
				[chatViewController.allFriendsSwitch setValue:value];
				[mapViewController.allFriendsSwitch setValue:value];
			}
			else if ([chatViewController.view superview]) 
			{
				[arViewController.allFriendsSwitch setValue:value];
				[mapViewController.allFriendsSwitch setValue:value];
			}
			else if ([mapViewController.view superview]) 
			{
				[arViewController.allFriendsSwitch setValue:value];
				[chatViewController.allFriendsSwitch setValue:value];
			}
			
            NSMutableArray *friendsIds = [[[DataManager shared].myFriendsAsDictionary allKeys] mutableCopy];
            [friendsIds addObject:[DataManager shared].currentFBUserId];// add me
            
            // Map/AR points
            //
            [mapPoints removeAllObjects]; 
            //
			// add only friends QB points
            NSMutableArray *friendsIdsWhoAlreadyAdded = [NSMutableArray array];
            for(UserAnnotation *mapAnnotation in allMapPoints){
                if([friendsIds containsObject:[mapAnnotation.fbUser objectForKey:kId]]){
                    [mapPoints addObject:mapAnnotation];
                    
                    [friendsIdsWhoAlreadyAdded addObject:[mapAnnotation.fbUser objectForKey:kId]];
                }
            }
            //
			// add checkin 
            for (UserAnnotation* checkin in allCheckins){
                if (![friendsIdsWhoAlreadyAdded containsObject:checkin.fbUserId]){
                    [mapPoints addObject:checkin];
                    [friendsIdsWhoAlreadyAdded addObject:checkin.fbUserId];
                }else{
                    // compare datetimes - add newest
                    NSDate *newCreateDateTime = checkin.createdAt;
                    
                    int index = [friendsIdsWhoAlreadyAdded indexOfObject:checkin.fbUserId];
                    NSDate *currentCreateDateTime = ((UserAnnotation *)[mapPoints objectAtIndex:index]).createdAt;
                    
                    if([newCreateDateTime compare:currentCreateDateTime] == NSOrderedDescending){ //The receiver(newCreateDateTime) is later in time than anotherDate, NSOrderedDescending
                        [mapPoints replaceObjectAtIndex:index withObject:checkin];
                        [friendsIdsWhoAlreadyAdded replaceObjectAtIndex:index withObject:checkin.fbUserId];
                    }
                }
            }
			
			
            // Chat points
            //
            [chatPoints removeAllObjects]; 
            //
			// add only friends QB points
            for(UserAnnotation *mapAnnotation in allChatPoints){
                if([friendsIds containsObject:[mapAnnotation.fbUser objectForKey:kId]]){
                    [chatPoints addObject:mapAnnotation];
                }
            }
			//
			// add all checkins
            [chatPoints addObjectsFromArray:allCheckins];
			
            [mapViewController pointsUpdated];
            [arViewController pointsUpdated];
            [chatViewController pointsUpdated];
            
            
            
            // show Alert with info at startapp
            if([[DataManager shared] isFirstStartApp]){
                [[DataManager shared] setFirstStartApp:NO];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"'World' mode", nil) 
                                                                message:NSLocalizedString(@"You can see and chat with all users within 10km. \
                                                                    Increase search radius using slider (left). \
                                                                                          Switch to 'Facebook only' mode (bottom right) to see your friends and their check-ins only.", nil)    
                                                               delegate:nil 
                                                      cancelButtonTitle:NSLocalizedString(@"Ok", nil) 
                                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
			
	}         
	break;
            
        // show friends
        case 0:{
			if ([arViewController.view superview])
			{
				[chatViewController.allFriendsSwitch setValue:value];
				[mapViewController.allFriendsSwitch setValue:value];
			}
			else if ([chatViewController.view superview]) 
			{
				[arViewController.allFriendsSwitch setValue:value];
				[mapViewController.allFriendsSwitch setValue:value];
			}
			else if ([mapViewController.view superview]) 
			{
				[arViewController.allFriendsSwitch setValue:value];
				[chatViewController.allFriendsSwitch setValue:value];
			}
			
			
            // Map/AR points
            //
            [mapPoints removeAllObjects]; 
            //
            // 1. add All from QB
            NSMutableArray *friendsIdsWhoAlreadyAdded = [NSMutableArray array];
            for(UserAnnotation *mapAnnotation in allMapPoints){
                [mapPoints addObject:mapAnnotation];
                [friendsIdsWhoAlreadyAdded addObject:mapAnnotation.fbUserId];
            }
            //
			// add checkin 
            for (UserAnnotation* checkin in allCheckins){
                if (![friendsIdsWhoAlreadyAdded containsObject:checkin.fbUserId]){
                    [mapPoints addObject:checkin];
                    [friendsIdsWhoAlreadyAdded addObject:checkin.fbUserId];
                }else{
                    // compare datetimes - add newest
                    NSDate *newCreateDateTime = checkin.createdAt;
                    
                    int index = [friendsIdsWhoAlreadyAdded indexOfObject:checkin.fbUserId];
                    NSDate *currentCreateDateTime = ((UserAnnotation *)[mapPoints objectAtIndex:index]).createdAt;
					
                    if([newCreateDateTime compare:currentCreateDateTime] == NSOrderedDescending){ //The receiver(newCreateDateTime) is later in time than anotherDate, NSOrderedDescending
                        [mapPoints replaceObjectAtIndex:index withObject:checkin];
                        [friendsIdsWhoAlreadyAdded replaceObjectAtIndex:index withObject:checkin.fbUserId];
                    }
                }
            }
            
            
            // Chat points
            //
            [chatPoints removeAllObjects];
            //
            // 2. add Friends from FB
            [chatPoints addObjectsFromArray:allChatPoints];
            //
            // add all checkins
            [chatPoints addObjectsFromArray:allCheckins];
			
            
            
            [mapViewController pointsUpdated];
            [arViewController pointsUpdated];
            [chatViewController pointsUpdated];
        }
			break;
    }
}

- (BOOL)isAllShowed{
    if(mapViewController.allFriendsSwitch.value == 0){
        return YES;
    }
    
    return NO;
}

- (void)showRadar
{
    if([arViewController.view superview] == nil)
	{
        [self.view addSubview:arViewController.view];
        [arViewController.view setFrame:CGRectMake(0, 0, 320, 462)];
    }
    [mapViewController.view removeFromSuperview];
    [chatViewController.view removeFromSuperview];
    
    // start AR
    [arViewController displayAR];
}

- (void)showChat{
	
    if([chatViewController.view superview] == nil){
        [self.view addSubview:chatViewController.view];
        [chatViewController.view setFrame:CGRectMake(0, 0, 320, 387)];
    }
    [mapViewController.view removeFromSuperview];
    [arViewController.view removeFromSuperview];
    
    // stop AR
    [arViewController dissmisAR];
}

- (void)showMap{
	
    if([mapViewController.view superview] == nil){
        [self.view addSubview:mapViewController.view];
        [mapViewController.view setFrame:CGRectMake(0, 0, 320, 462)];
    }
    [chatViewController.view removeFromSuperview];
    [arViewController.view removeFromSuperview];
    
    // stop AR
    [arViewController dissmisAR];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    myCurrentLocation = [newLocation retain];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"Error: %@", [error description]);
}


/*
 Touch on marker
 */
- (void)touchOnMarker:(UIView *)marker{
    // get user name & id
    NSString *userName = nil;
    if([marker isKindOfClass:MapMarkerView.class]){ // map
        userName = ((MapMarkerView *)marker).userName.text;
        self.selectedUserAnnotation = ((MapMarkerView *)marker).annotation;
    }else if([marker isKindOfClass:ARMarkerView.class]){ // ar
        userName = ((ARMarkerView *)marker).userName.text;
        self.selectedUserAnnotation = ((ARMarkerView *)marker).userAnnotation;
    }else if([marker isKindOfClass:UITableViewCell.class]){ // chat
        userName = ((UILabel *)[marker viewWithTag:1105]).text;
        self.selectedUserAnnotation = [chatPoints objectAtIndex:marker.tag];
    }
	
	NSString* title;
	NSString* subTitle;
	
	title = userName;
	if ([selectedUserAnnotation.userStatus length] >=6)
	{
		if ([[self.selectedUserAnnotation.userStatus substringToIndex:6] isEqualToString:fbidIdentifier])
		{
			subTitle = [self.selectedUserAnnotation.userStatus substringFromIndex:[self.selectedUserAnnotation.userStatus rangeOfString:quoteDelimiter].location+1];
		}
		else 
		{
			subTitle = self.selectedUserAnnotation.userStatus;
		}
	}
	else 
	{
		subTitle = self.selectedUserAnnotation.userStatus;
	}
	
	subTitle = [NSString stringWithFormat:@"''%@''", subTitle];
    
    // show action sheet
    [self showActionSheetWithTitle:title andSubtitle:subTitle];
}

- (void)showActionSheetWithTitle:(NSString *)title andSubtitle:(NSString *)subtitle
{
    // check yourself
    if([selectedUserAnnotation.fbUserId isEqualToString:[DataManager shared].currentFBUserId]){
        return;
    }
    
    
    // show Action Sheet
    //
    // add "Quote" item only in Chat
	if (chatViewController.view.superview)
	{
		userActionSheet = [[UIActionSheet alloc] initWithTitle:title 
													  delegate:self 
											 cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
										destructiveButtonTitle:nil 
											 otherButtonTitles:NSLocalizedString(@"Send private FB message", nil), NSLocalizedString(@"View FB profile", nil),
						   NSLocalizedString(@"Reply with quote", nil), nil];
        userActionSheet.tag = 1;
	}
	else 
	{
		userActionSheet = [[UIActionSheet alloc] initWithTitle:title 
													  delegate:self 
											 cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
										destructiveButtonTitle:nil 
											 otherButtonTitles:NSLocalizedString(@"Reply in public chat", nil), NSLocalizedString(@"Send private FB message", nil), NSLocalizedString(@"View FB profile", nil),
						    nil];
        userActionSheet.tag = 2;
	}
	
	UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 280, 15)];
	titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.text = title;
	titleLabel.numberOfLines = 0;
	[userActionSheet addSubview:titleLabel];
	
	UILabel* subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 55)];
	subTitleLabel.font = [UIFont boldSystemFontOfSize:12.0];
	subTitleLabel.textAlignment = UITextAlignmentCenter;
	subTitleLabel.backgroundColor = [UIColor clearColor];
	subTitleLabel.textColor = [UIColor whiteColor];
	subTitleLabel.text = subtitle;
	subTitleLabel.numberOfLines = 0;
	[userActionSheet addSubview:subTitleLabel];
	
	[subTitleLabel release];
	[titleLabel release];
	userActionSheet.title = @"";

	// Show
	[userActionSheet showFromTabBar:self.tabBarController.tabBar];
	
	CGRect actionSheetRect = userActionSheet.frame;
	actionSheetRect.origin.y -= 60.0;
	actionSheetRect.size.height = 300.0;
	[userActionSheet setFrame:actionSheetRect];
	
	for (int counter = 0; counter < [[userActionSheet subviews] count]; counter++) 
	{
		UIView *object = [[userActionSheet subviews] objectAtIndex:counter];
		if (![object isKindOfClass:[UILabel class]])
		{
			CGRect frame = object.frame;
			frame.origin.y = frame.origin.y + 60.0;
			object.frame = frame;
		}
	}
}

// Add Quote data to annotation
- (void)addQuoteDataToAnnotation:(UserAnnotation *)annotation geoData:(QBLGeoData *)geoData{
    // get quoted geodata
    annotation.userStatus = [geoData.status substringFromIndex:[geoData.status rangeOfString:quoteDelimiter].location+1];
    
    NSString* authorFBId = [[geoData.status substringFromIndex:6] substringToIndex:[geoData.status rangeOfString:nameIdentifier].location-6];
    annotation.quotedUserFBId = authorFBId;
    
    NSString* authorName = [[geoData.status substringFromIndex:[geoData.status rangeOfString:nameIdentifier].location+6] substringToIndex:[[geoData.status substringFromIndex:[geoData.status rangeOfString:nameIdentifier].location+6] rangeOfString:dateIdentifier].location];
    annotation.quotedUserName = authorName;
    
    NSString* date = [[geoData.status substringFromIndex:[geoData.status rangeOfString:dateIdentifier].location+6] substringToIndex:[[geoData.status substringFromIndex:[geoData.status rangeOfString:dateIdentifier].location+6] rangeOfString:photoIdentifier].location];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss Z"];
    annotation.quotedMessageDate = [formatter dateFromString:date];
    
    NSString* photoLink = [[geoData.status substringFromIndex:[geoData.status rangeOfString:photoIdentifier].location+7] substringToIndex:[[geoData.status substringFromIndex:[geoData.status rangeOfString:photoIdentifier].location+7] rangeOfString:messageIdentifier].location];
    annotation.quotedUserPhotoURL = photoLink;
    
    NSString* message = [[geoData.status substringFromIndex:[geoData.status rangeOfString:messageIdentifier].location+5] substringToIndex:[[geoData.status substringFromIndex:[geoData.status rangeOfString:messageIdentifier].location+5] rangeOfString:quoteDelimiter].location];
    annotation.quotedMessageText = message;
}

/*
 Add new annotation to map,chat,ar
 */
- (void)addNewAnnotationToMapChatARForFBUser:(NSDictionary *)fbUser withGeoData:(QBLGeoData *)geoData addToTop:(BOOL)toTop withReloadTable:(BOOL)reloadTable{
    
    // create new user annotation
    UserAnnotation *newAnnotation = [[UserAnnotation alloc] init];
    newAnnotation.geoDataID = geoData.ID;
    newAnnotation.coordinate = geoData.location.coordinate;
	
	if ([geoData.status length] >= 6){
		if ([[geoData.status substringToIndex:6] isEqualToString:fbidIdentifier]){
            // add Quote
            [self addQuoteDataToAnnotation:newAnnotation geoData:geoData];
            
		}else {
			newAnnotation.userStatus = geoData.status;
		}
        
	}else {
		newAnnotation.userStatus = geoData.status;
	}
	
    newAnnotation.userName = [fbUser objectForKey:kName];
    newAnnotation.userPhotoUrl = [fbUser objectForKey:kPicture];
    newAnnotation.fbUserId = [fbUser objectForKey:kId];
    newAnnotation.fbUser = fbUser;
    newAnnotation.qbUserID = geoData.user.ID;
	newAnnotation.createdAt = geoData.createdAt;
    
    newAnnotation.distance  = [geoData.location distanceFromLocation:[[QBLLocationDataSource instance] currentLocation]];
    
    NSArray *friendsIds = [[DataManager shared].myFriendsAsDictionary allKeys]; 
    
    // Add to Chat
    BOOL addedToCurrentChatState = NO;
	if (toTop){
		[allChatPoints insertObject:newAnnotation atIndex:0];
        if([self isAllShowed] || [friendsIds containsObject:newAnnotation.fbUserId] || 
                                    [newAnnotation.fbUserId isEqualToString:[DataManager shared].currentFBUserId]){
            [chatPoints insertObject:newAnnotation atIndex:0];
            addedToCurrentChatState = YES;
        }
	}else {
		[allChatPoints insertObject:newAnnotation atIndex:[allChatPoints count]-1];
        if([self isAllShowed] || [friendsIds containsObject:newAnnotation.fbUserId] || 
                                    [newAnnotation.fbUserId isEqualToString:[DataManager shared].currentFBUserId]){
            [chatPoints insertObject:newAnnotation atIndex:[chatPoints count]-1];
            addedToCurrentChatState = YES;
        }
	}
    //
    if(addedToCurrentChatState && reloadTable){
        NSIndexPath *newMessagePath = [NSIndexPath indexPathForRow:0 inSection:0];
        NSArray *newRows = [[NSArray alloc] initWithObjects:newMessagePath, nil];
        [chatViewController.messagesTableView insertRowsAtIndexPaths:newRows withRowAnimation:UITableViewRowAnimationNone];
        [newRows release];
    }
    //
    // save messages ids
    [chatIDs addObject:[NSString stringWithFormat:@"%d", geoData.ID]];
    
	
    // Check for Map
    BOOL isExistPoint = NO;
    for (UserAnnotation *annotation in mapViewController.mapView.annotations)
	{
        // already exist, change status
        if([newAnnotation.fbUserId isEqualToString:annotation.fbUserId])
		{
            annotation.userStatus = newAnnotation.userStatus;
            MapMarkerView *marker = (MapMarkerView *)[mapViewController.mapView viewForAnnotation:annotation];
            marker.userStatus.text = annotation.userStatus;
            isExistPoint = YES;
            break;
        }
    }
    
    
    // Check for AR
    if(isExistPoint){
        for (ARMarkerView *marker in arViewController.coordinateViews)
		{
            // already exist, change status
            if([newAnnotation.fbUserId isEqualToString:marker.userAnnotation.fbUserId])
			{
                ARMarkerView *marker = (ARMarkerView *)[arViewController viewForExistAnnotation:newAnnotation];
                marker.userStatus.text = newAnnotation.userStatus;
                isExistPoint = YES;
                break;
            }
        }
    }
    

    // new -> add to Map, AR
    if(!isExistPoint){
        BOOL addedToCurrentMapState = NO;
        [allMapPoints addObject:newAnnotation];
        if([self isAllShowed] || [friendsIds containsObject:newAnnotation.fbUserId]){
            [mapPoints addObject:newAnnotation];
            addedToCurrentMapState = YES;
        }
        //
        if(addedToCurrentMapState){
            [mapViewController.mapView addAnnotation:newAnnotation];
            [arViewController addUserAnnotation:newAnnotation];
        }
    }
	
	[newAnnotation release];
}

// convert map array of QBLGeoData objects to UserAnnotations a
- (void)convertMapArray:(NSArray*)fbUsers;
{
	
    CLLocationCoordinate2D coordinate;
    int index = 0;
    
    NSArray *mapPointsCopy = [NSArray arrayWithArray:allMapPoints];
    
	// look through array for geodatas
	for (QBLGeoData *geodata in mapPointsCopy) 
	{	
        NSDictionary *fbUser = nil;
        for(NSDictionary *user in fbUsers){
            if([geodata.user.facebookID isEqualToString:[user objectForKey:kId]]){
                fbUser = user;
                break;
            }
        }
		
		if ([geodata.user.facebookID isEqualToString:[DataManager shared].currentFBUserId])
		{
			coordinate.latitude = self.myCurrentLocation.coordinate.latitude;
			coordinate.longitude = self.myCurrentLocation.coordinate.longitude;
		}
		else 
		{
			coordinate.latitude = geodata.latitude;
			coordinate.longitude = geodata.longitude;
		}
		
        UserAnnotation *mapAnnotation = [[UserAnnotation alloc] init];
        mapAnnotation.geoDataID = geodata.ID;
        mapAnnotation.coordinate = coordinate;
        mapAnnotation.userStatus = geodata.status;
        mapAnnotation.userName = [fbUser objectForKey:kName];
        mapAnnotation.userPhotoUrl = [fbUser objectForKey:kPicture];
        mapAnnotation.fbUserId = [fbUser objectForKey:kId];
        mapAnnotation.fbUser = fbUser;
        mapAnnotation.qbUserID = geodata.user.ID;
        mapAnnotation.createdAt = geodata.createdAt;
        [allMapPoints replaceObjectAtIndex:index withObject:mapAnnotation];
        
        // own centered
        if([[mapAnnotation.fbUser objectForKey:kId] isEqualToString:[[DataManager shared].currentFBUser objectForKey:kId]]){
            MKCoordinateRegion region;
            //Set Zoom level using Span
            MKCoordinateSpan span;  
            region.center = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
            span.latitudeDelta = 100;
            span.longitudeDelta = 100;
            region.span = span;
            [mapViewController.mapView setRegion:region animated:TRUE];
        }
        
        [mapAnnotation release];
        
        ++index;
	}
	
    // all data was retrieved
    ++initState;
    NSLog(@"MAP OK");
    if(initState == 3){
        [self endOfRetrieveInitialData];
    }
}

// convert chat array of QBLGeoData objects to UserAnnotations a
- (void)convertChatArray:(NSArray*)fbUsers;
{
    CLLocationCoordinate2D coordinate;
    int index = 0;
    NSArray *chatPointsCopy = [NSArray arrayWithArray:allChatPoints];
    
    for (QBLGeoData *geodata in chatPointsCopy) 
    {	
        NSDictionary *fbUser = nil;
        for(NSDictionary *user in fbUsers){
            if([geodata.user.facebookID isEqualToString:[user objectForKey:kId]]){
                fbUser = user;
                break;
            }
        }
        
        coordinate.latitude = geodata.latitude;
        coordinate.longitude = geodata.longitude;
        UserAnnotation *chatAnnotation = [[UserAnnotation alloc] init];
        chatAnnotation.geoDataID = geodata.ID;
        chatAnnotation.coordinate = coordinate;
		
		if ([geodata.status length] >= 6){
			if ([[geodata.status substringToIndex:6] isEqualToString:fbidIdentifier]){
				// add Quote
                [self addQuoteDataToAnnotation:chatAnnotation geoData:geodata];
			
            }else {
				chatAnnotation.userStatus = geodata.status;
			}
		}else {
			chatAnnotation.userStatus = geodata.status;
		}
		
		chatAnnotation.userName = [NSString stringWithFormat:@"%@ %@", 
                                   [fbUser objectForKey:kFirstName], [fbUser objectForKey:kLastName]];
		chatAnnotation.userPhotoUrl = [fbUser objectForKey:kPicture];
		chatAnnotation.fbUserId = [fbUser objectForKey:kId];
		chatAnnotation.fbUser = fbUser;
        chatAnnotation.qbUserID = geodata.user.ID;
		chatAnnotation.createdAt = geodata.createdAt;

        chatAnnotation.distance  = [geodata.location distanceFromLocation:[[QBLLocationDataSource instance] currentLocation]];
		
		[allChatPoints replaceObjectAtIndex:index withObject:chatAnnotation];
		[chatAnnotation release];
	
		[chatIDs addObject:[NSString stringWithFormat:@"%d", geodata.ID]];
        
		++index;
	}
    
    // all data was retrieved
    ++initState;
    if(initState == 3){
        [self endOfRetrieveInitialData];
    }
}

// convert checkins array UserAnnotations
- (void)convertCheckinsArray:(NSArray *)checkins{
    
    CLLocationCoordinate2D coordinate;
    
    if(allCheckins == nil){
        allCheckins = [[NSMutableArray alloc] init];
    }
    
    // Collect checkins
    for(NSDictionary *checkin in checkins){
        
        // get checkin's owner
        NSString *fbUserID = [[checkin objectForKey:kFrom] objectForKey:kId];
        
        NSDictionary *fbUser;
        if([fbUserID isEqualToString:[DataManager shared].currentFBUserId]){
            fbUser = [DataManager shared].currentFBUser; 
        }else{
            fbUser = [[DataManager shared].myFriendsAsDictionary objectForKey:fbUserID];
        }
        
        // skip if not friend or own
        if(!fbUser){
            continue;
        }
        
        if([checkin objectForKey:kPlace] == nil){
            continue;
        }
        
        // status
        NSString *status = nil;
        NSString* country = [[[checkin objectForKey:kPlace] objectForKey:kLocation] objectForKey:kCountry];
        NSString* city = [[[checkin objectForKey:kPlace] objectForKey:kLocation] objectForKey:kCity];
        NSString* name = [[checkin objectForKey:kPlace] objectForKey:kName];
        if ([country length]){
            status = [NSString stringWithFormat:@"I'm at %@ in %@, %@.", name, country, city];
        }else {
            status = [NSString stringWithFormat:@"I'm at %@", name];
        }
        
        // datetime
        NSString* time = [checkin objectForKey:kCreatedTime];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setLocale:[NSLocale currentLocale]];
        [df setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
        NSDate *createdAt = [df dateFromString:time];
        [df release];
        
        // coordinate
        coordinate.latitude = [[[[checkin objectForKey:kPlace] objectForKey:kLocation] objectForKey:kLatitude] floatValue];
        coordinate.longitude = [[[[checkin objectForKey:kPlace] objectForKey:kLocation] objectForKey:kLongitude] floatValue];
        
        UserAnnotation *checkinAnnotation = [[UserAnnotation alloc] init];
        checkinAnnotation.geoDataID = -1;
        checkinAnnotation.coordinate = coordinate;
        checkinAnnotation.userStatus = status;
        checkinAnnotation.userName = [[checkin objectForKey:kFrom] objectForKey:kName];
        checkinAnnotation.userPhotoUrl = [fbUser objectForKey:kPicture];
        checkinAnnotation.fbUserId = [fbUser objectForKey:kId];
        checkinAnnotation.fbUser = fbUser;
        checkinAnnotation.createdAt = createdAt;
		
        CLLocation *checkinLocation = [[CLLocation alloc] initWithLatitude: coordinate.latitude longitude: coordinate.longitude];
        checkinAnnotation.distance = [checkinLocation distanceFromLocation:[[QBLLocationDataSource instance] currentLocation]];
        [checkinLocation release];
        
        [allCheckins addObject:checkinAnnotation];
        [checkinAnnotation release];
    }	
}

- (void)endOfRetrieveInitialData{
    
    // show all
    [self allFriendsSwitchValueDidChanged:mapViewController.allFriendsSwitch];

    [arViewController.allFriendsSwitch setEnabled:YES];
    [mapViewController.allFriendsSwitch setEnabled:YES];
    [chatViewController.allFriendsSwitch setEnabled:YES];
    
    
    // start timer for check for new points
    updateTimre = [[NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForNewPoints:) userInfo:nil repeats:YES] retain];
}


#pragma mark-
#pragma mark FBServiceResultDelegate

-(void)completedWithFBResult:(FBServiceResult *)result context:(id)context{
    switch (result.queryType) {
            
        // get Users profiles
        case FBQueriesTypesUsersProfiles:{
            NSString *ctx = (NSString *)context;
            
            // Map init
            if([context isKindOfClass:NSString.class] && [ctx isEqualToString:mapFBUsers]){
                
                // convertation
                [self convertMapArray:[result.body allValues]];
                
            // Chat init
            }else if([context isKindOfClass:NSString.class] && [ctx isEqualToString:chatFBUsers]){
                // convertation
                [self convertChatArray:[result.body allValues]];
                
            // check new one
            }else{
                for (QBLGeoData *geoData in context) {	
                    
                    // get vk user
                    NSDictionary *fbUser = nil;
                    for(NSDictionary *user in [result.body allValues]){
                        if([geoData.user.facebookID isEqualToString:[[user objectForKey:kId] description]]){
                            fbUser = user;
                            break;
                        }
                    }
                    
                    // add new Annotation to map/chat/ar
                    [self addNewAnnotationToMapChatARForFBUser:fbUser withGeoData:geoData addToTop:YES withReloadTable:YES];
                }        
            }
                
            break;
        }
        default:
            break;
    }
}

-(void)completedWithFBResult:(FBServiceResult *)result
{
    switch (result.queryType) 
    {
        // Get Friends checkins
        case FBQueriesTypesFriendsGetCheckins:{
            --numberOfCheckinsRetrieved;
            
            NSLog(@"numberOfCheckinsRetrieved=%d", numberOfCheckinsRetrieved);
            
            for(NSDictionary *checkinsResult in result.body){
                if([checkinsResult isKindOfClass:NSNull.class]){
                    continue;
                }
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                NSArray *checkins = [[parser objectWithString:(NSString *)([checkinsResult objectForKey:kBody])] objectForKey:kData];
                [parser release];
                
                if ([checkins count]){
                    // convert checkins
                    [self convertCheckinsArray:checkins];
                    
                }
            }
            
            // if there isn't any checkins
            if(numberOfCheckinsRetrieved == 0 && [allCheckins count] == 0){
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning!", nil) 
                                                                message:NSLocalizedString(@"Unfortunately, your friends did not shared locations. You can change the switcher above for watching all application users.", nil) 
                                                                delegate:nil 
                                                       cancelButtonTitle:NSLocalizedString(@"Okay.", nil) 
                                                       otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                
                if(updateTimre == nil){
                    ++initState;
                    if(initState == 3){
                        [self endOfRetrieveInitialData];
                    }
                }
                
            // all data was retrieved
            }else if(numberOfCheckinsRetrieved == 0){
                ++initState;
                if(initState == 3){
                    [self endOfRetrieveInitialData];
                }
            }
        }
        break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark QB ActionStatusDelegate

- (void)completedWithResult:(Result *)result context:(void *)contextInfo{
    // get points result
	if([result isKindOfClass:[QBLGeoDataPagedResult class]])
	{
        if (result.success){
            QBLGeoDataPagedResult *geoDataSearchResult = (QBLGeoDataPagedResult *)result;
            
            // update map
            if([((NSString *)contextInfo) isEqualToString:mapSearch]){
				
				// store all map points
                [allMapPoints release];
                allMapPoints = [geoDataSearchResult.geodata mutableCopy];
                
                // get string of fb users ids
                NSMutableArray *fbMapUsersIds = [[NSMutableArray alloc] init];
                for (QBLGeoData *geodata in geoDataSearchResult.geodata){
                    [fbMapUsersIds addObject:geodata.user.facebookID];
                }
                //
				NSMutableString* ids = [[NSMutableString alloc] init];
				for (NSString* userID in fbMapUsersIds)
				{
					[ids appendFormat:[NSString stringWithFormat:@"%@,", userID]];
				}
				
				// get FB info for obtained QB locations
				[[FBService shared] usersProfilesWithIds:[ids substringToIndex:[ids length]-1] 
                                                delegate:self 
                                                 context:mapFBUsers];
                
                [fbMapUsersIds release];
				[ids release];
                
            // update chat
            }else if([((NSString *)contextInfo) isEqualToString:chatSearch]){
                
                // store all chat points
                [allChatPoints release];
                allChatPoints = [geoDataSearchResult.geodata mutableCopy];
                
                // get fb users info
                NSMutableSet *fbChatUsersIds = [[NSMutableSet alloc] init];
                for (QBLGeoData *geodata in geoDataSearchResult.geodata){
                    [fbChatUsersIds addObject:geodata.user.facebookID];
                }
                //
                NSMutableString* ids = [[NSMutableString alloc] init];
				for (NSString* userID in fbChatUsersIds)
				{
					[ids appendFormat:[NSString stringWithFormat:@"%@,", userID]];
				}

                // get FB info for obtained QB chat messages
				[[FBService shared] usersProfilesWithIds:[ids substringToIndex:[ids length]-1] 
                                                delegate:self 
                                                 context:chatFBUsers];
                [fbChatUsersIds release];
                [ids release];
            }
        }
    }
}

- (void)completedWithResult:(Result *)result {
    // get points result - check for new one
	if([result isKindOfClass:[QBLGeoDataPagedResult class]])
	{
        
        if (result.success){
            QBLGeoDataPagedResult *geoDataSearchResult = (QBLGeoDataPagedResult *)result;

            if([geoDataSearchResult.geodata count] == 0){
                return;
            }
            
            // get fb users info
            NSMutableArray *fbChatUsersIds = nil;
            NSMutableArray *geodataProcessed = [NSMutableArray array];
            for (QBLGeoData *geodata in geoDataSearchResult.geodata){
                // skip if already exist
                if([chatIDs containsObject:[NSString stringWithFormat:@"%d", geodata.ID]]){
                    continue;
                }
                
                // skip own;
                if([DataManager shared].currentQBUser.ID == geodata.user.ID){
                    continue;
                }
                
                // collect users ids
                if(fbChatUsersIds == nil){
                    fbChatUsersIds = [[NSMutableArray alloc] init];
                }
                [fbChatUsersIds addObject:geodata.user.facebookID];
                
                [geodataProcessed addObject:geodata];
            }
            
            if(fbChatUsersIds == nil){
                return;
            }
            
            //
            [[FBService shared] usersProfilesWithIds:[fbChatUsersIds stringComaSeparatedValue] delegate:self context:geodataProcessed];
            //
            [fbChatUsersIds release];
        }
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    switch (buttonIndex) {
        case 0:{ 
            
            // Send FB message
            if(actionSheet.tag == 1){
                [self actionSheetSendPrivateFBMessage];
                
            // Reply in public chat
            }else{
                if(!chatViewController.view.superview)
                {
                    if (segmentControl.numberOfSegments == 2)
                    {
                        segmentControl.selectedSegmentIndex = 1;
                    }
                    else 
                    {
                        segmentControl.selectedSegmentIndex = 2;
                    }
                    
                    [self showChat];
                }
                
                // quote action
                [chatViewController addQuote];
                [chatViewController.messageField becomeFirstResponder];
            }
        }

            break;
            
        // View personal fb page
        case 1: 
        {
            // View personal FB page
            if(actionSheet.tag == 1){
                // Show profile
                NSString *url = [NSString stringWithFormat:@"http://www.facebook.com/profile.php?id=%@",selectedUserAnnotation.fbUserId];
                
                WebViewController *webViewControleler = [[WebViewController alloc] init];
                webViewControleler.urlAdress = url;
                [self.navigationController pushViewController:webViewControleler animated:YES];
                [webViewControleler autorelease];
                
            // Send FB message
            }else{
                [self actionSheetSendPrivateFBMessage];
            }
            
           
        }
            break;

        // Quote or Exit
        case 2: 
            // reply with quote
            if(actionSheet.tag == 1){
                // quote action
                [chatViewController addQuote];
                [chatViewController.messageField becomeFirstResponder];
                
             // View personal FB page
            }else{
                // Show profile
                NSString *url = [NSString stringWithFormat:@"http://www.facebook.com/profile.php?id=%@",selectedUserAnnotation.fbUserId];
                
                WebViewController *webViewControleler = [[WebViewController alloc] init];
                webViewControleler.urlAdress = url;
                [self.navigationController pushViewController:webViewControleler animated:YES];
                [webViewControleler autorelease];
            }
			
            break;
            
        default:
            break;
    }
    
    [userActionSheet release];
    userActionSheet = nil;
    
    self.selectedUserAnnotation = nil;
}

- (void) actionSheetSendPrivateFBMessage{
    NSString *selectedFriendId = selectedUserAnnotation.fbUserId;
    
    // get conversation
    Conversation *conversation = [[DataManager shared].historyConversation objectForKey:selectedFriendId];
    if(conversation == nil){
        // 1st message -> create conversation
        
        Conversation *newConversation = [[Conversation alloc] init];
        
        // add to
        NSMutableDictionary *to = [NSMutableDictionary dictionary];
        [to setObject:selectedFriendId forKey:kId];
        [to setObject:[selectedUserAnnotation.fbUser objectForKey:kName] forKey:kName];
        newConversation.to = to;
        
        // add messages
        NSMutableArray *emptryArray = [[NSMutableArray alloc] init];
        newConversation.messages = emptryArray;
        [emptryArray release];
        
        [[DataManager shared].historyConversation setObject:newConversation forKey:selectedFriendId];
        [newConversation release];
        
        conversation = newConversation;
    }
    
    // show Chat
    FBChatViewController *chatController = [[FBChatViewController alloc] initWithNibName:@"FBChatViewController" bundle:nil];
    chatController.chatHistory = conversation;
    [self.navigationController pushViewController:chatController animated:YES];
    [chatController release];

}

@end
