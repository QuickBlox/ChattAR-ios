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
#import "ARMarkerView.h"
#import "MessagesViewController.h"
#import "WebViewController.h"

#import "QBCheckinModel.h"
#import "QBChatMessageModel.h"
#import "FBCheckinModel.h"


@interface MapChatARViewController ()

@property (nonatomic, retain) CLLocation* myCurrentLocation;

- (UserAnnotation *)lastChatMessage:(BOOL)ignoreOwn;

- (void)processQBCheckins:(NSArray *)data;
- (void)processQBChatMessages:(NSArray *)data;
- (void)processFBCheckins:(NSArray *)data;

- (void)addNewPointToMapAR:(UserAnnotation *)point;
- (void)addNewMessageToChat:(UserAnnotation *)message addToTop:(BOOL)toTop withReloadTable:(BOOL)reloadTable;

@end

@implementation MapChatARViewController

@synthesize mapViewController, chatViewController, arViewController;
@synthesize segmentControl;
@synthesize mapPoints, chatPoints;
@synthesize chatMessagesIDs, mapPointsIDs, fbCheckinsIDs;
@synthesize userActionSheet, allMapPoints, allCheckins, allChatPoints;
@synthesize selectedUserAnnotation;
@synthesize locationManager, myCurrentLocation;
@synthesize initedFromCache;
@synthesize allFriendsSwitch;
@synthesize initState;


#pragma mark -
#pragma mark UIViewController life

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
        
        
        // Main storage
        allChatPoints = [[NSMutableArray alloc] init];
        allMapPoints = [[NSMutableArray alloc] init];
        allCheckins = [[NSMutableArray alloc] init];
        
        
        // Storage based on switch World/Friends
        mapPoints = [[NSMutableArray alloc] init];
        chatPoints = [[NSMutableArray alloc] init];
		
        
        // IDs
        chatMessagesIDs = [[NSMutableArray alloc] init];
        mapPointsIDs = [[NSMutableArray alloc] init];
        fbCheckinsIDs = [[NSMutableArray alloc] init];
        
        
        
        // Current location
        myCurrentLocation = [[CLLocation alloc] init];
        //
		locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self; // send loc updates to myself
		
        
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
    
    [chatMessagesIDs release];
    [mapPointsIDs release];
    [fbCheckinsIDs release];
    
    [userActionSheet release];
	
	[locationManager release];
	[myCurrentLocation release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLogout object:nil];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[locationManager startUpdatingLocation];
	
    // AR/Map/Chat segment
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
    
    // add All/Friends switch
	allFriendsSwitch = [CustomSwitch customSwitch];
    [allFriendsSwitch setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin)];
    [allFriendsSwitch setCenter:CGPointMake(280, 360)];
    [allFriendsSwitch setValue:worldValue];
    [allFriendsSwitch scaleSwitch:0.9];
    [allFriendsSwitch addTarget:self action:@selector(allFriendsSwitchValueDidChanged:) forControlEvents:UIControlEventValueChanged];
	[allFriendsSwitch setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:allFriendsSwitch];
	
    
    // map/chat delefates
    mapViewController.delegate = self;
    chatViewController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(!isInitialized){
        
        self.initState = 0;
        
        // show ar/map
        [segmentControl setSelectedSegmentIndex:0];
        [self segmentValueDidChanged:segmentControl];
        
        
        // get data from QuickBlox
        [self getQBGeodatas];
        
        
        // get checkins for all friends
        numberOfCheckinsRetrieved = ceil([[DataManager shared].myFriends count]/fmaxRequestsInBatch);
        NSLog(@"Checkins Parts=%d", numberOfCheckinsRetrieved);
        [self getFBCheckins];
        

        isInitialized = YES;
        
        
        // show Alert with info at startapp
        if([[DataManager shared] isFirstStartApp]){
            [[DataManager shared] setFirstStartApp:NO];
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"'World' mode", nil) 
                                                            message:NSLocalizedString(@"You can see and chat with all\nusers within 10km. Increase\nsearch radius using slider (left). \nSwitch to 'Facebook only' mode (bottom right) to see your friends and their check-ins only.", nil)    
                                                           delegate:nil 
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", nil) 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.allFriendsSwitch = nil;
    
    [updateTimre invalidate];
    [updateTimre release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark AR/Map/Chat

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
    
    // move wheel to front
    if(activityIndicator){
        [self.view bringSubviewToFront:activityIndicator];
    }
    //
    // move all/friends switch to front
    [self.view bringSubviewToFront:allFriendsSwitch];
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


#pragma mark -
#pragma mark All/Friends

// switch All/Friends
- (void)allFriendsSwitchValueDidChanged:(id)sender{
    float origValue = [(CustomSwitch *)sender value];
    int stateValue;
    if(origValue >= worldValue){
        stateValue = 1;
    }else if(origValue <= friendsValue){
        stateValue = 0;
    }
    
    switch (stateValue) {
        // show Friends
        case 0:{
            [self showFriends]; 
        }
        break;
            
        // show World
        case 1:{
			[self showWorld];
        }
        break;
    }
}

- (void) showWorld{
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
    
    
    
    // notify controllers
    [mapViewController refreshWithNewPoints:mapPoints];
    [arViewController refreshWithNewPoints:mapPoints];
    [chatViewController refresh];
}

- (void) showFriends{
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
    
    [mapViewController refreshWithNewPoints:mapPoints];
    [arViewController refreshWithNewPoints:mapPoints];
    [chatViewController refresh];
}

- (BOOL)isAllShowed{
    if(allFriendsSwitch.value == worldValue){
        return YES;
    }
    
    return NO;
}


#pragma mark -
#pragma mark Data requests

- (void)getQBGeodatas
{
    // get chat messages from cash
    NSDate *lastMessageDate = nil;
    NSArray *cashedChatMessages = [[DataManager shared] chatMessagesFromStorage];
    if([cashedChatMessages count] > 0){
        for(QBChatMessageModel *chatCashedMessage in cashedChatMessages){
            if(lastMessageDate == nil){
                lastMessageDate = ((UserAnnotation *)chatCashedMessage.body).createdAt;
            }
            [allChatPoints addObject:chatCashedMessage.body];
            [chatMessagesIDs addObject:[NSString stringWithFormat:@"%d", ((UserAnnotation *)chatCashedMessage.body).geoDataID]];
        }
    }
    
    NSLog(@"allChatPoints =%@", allChatPoints);
    
    // get map/ar points from cash
    NSDate *lastPointDate = nil;
    NSArray *cashedMapARPoints = [[DataManager shared] mapARPointsFromStorage];
    if([cashedMapARPoints count] > 0){
        for(QBCheckinModel *mapARCashedPoint in cashedMapARPoints){
            if(lastPointDate == nil){
                lastPointDate = ((UserAnnotation *)mapARCashedPoint.body).createdAt;
            }
            [allMapPoints addObject:mapARCashedPoint.body];
            [mapPointsIDs addObject:[NSString stringWithFormat:@"%d", ((UserAnnotation *)mapARCashedPoint.body).geoDataID]];
        }
    }
    
        NSLog(@"allMapPoints =%@", allMapPoints);
    
    // If we have info from cashe - show them
    if([allMapPoints count] > 0 || [allChatPoints count] > 0){
        [self showWorld];
        updateTimre = [[NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForNewPoints:) userInfo:nil repeats:YES] retain];
        
        initedFromCache = YES;
        
    }else{
        
        // show progress indicator
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.center = self.view.center;
        activityIndicator.tag = 1101;
        [self.view addSubview:activityIndicator];
        [activityIndicator startAnimating];
        

    }
    
    // get points for map
	QBLGeoDataGetRequest *searchMapARPointsRequest = [[QBLGeoDataGetRequest alloc] init];
	searchMapARPointsRequest.lastOnly = YES; // Only last location
	searchMapARPointsRequest.perPage = kGetGeoDataCount; // Pins limit for each page
	searchMapARPointsRequest.sortBy = GeoDataSortByKindCreatedAt;
    if(lastPointDate){
        searchMapARPointsRequest.minCreatedAt = lastPointDate;
    }
	[QBLocation geoDataWithRequest:searchMapARPointsRequest delegate:self context:mapSearch];
	[searchMapARPointsRequest release];
	
	// get points for chat
	QBLGeoDataGetRequest *searchChatMessagesRequest = [[QBLGeoDataGetRequest alloc] init];
	searchChatMessagesRequest.perPage = kGetGeoDataCount; // Pins limit for each page
	searchChatMessagesRequest.status = YES;
	searchChatMessagesRequest.sortBy = GeoDataSortByKindCreatedAt;
    if(lastMessageDate){
        searchChatMessagesRequest.minCreatedAt = lastMessageDate;
    }
	[QBLocation geoDataWithRequest:searchChatMessagesRequest delegate:self context:chatSearch];
	[searchChatMessagesRequest release];
}

- (void)getFBCheckins{
    // get checkins from cash
    NSArray *cashedFBCheckins = [[DataManager shared] checkinsFromStorage];
    if([cashedFBCheckins count] > 0){
        for(FBCheckinModel *checkinCashedPoint in cashedFBCheckins){
            [allCheckins addObject:checkinCashedPoint.body];
            [fbCheckinsIDs addObject:((UserAnnotation *)checkinCashedPoint.body).fbCheckinID];
        }
    }
    NSLog(@"fbCheckinsIDs=%@", fbCheckinsIDs);
    
    if([allCheckins count] > 0){
        [self showWorld];
    }
    
    // retrieve new
    if(numberOfCheckinsRetrieved != 0){
        [[FBService shared] performSelector:@selector(friendsCheckinsWithDelegate:) withObject:self afterDelay:1];
    }
}

// get new points from QuickBlox Location
- (void) checkForNewPoints:(NSTimer *) timer{
	QBLGeoDataGetRequest *searchRequest = [[QBLGeoDataGetRequest alloc] init];
	searchRequest.status = YES;
    searchRequest.sortBy = GeoDataSortByKindCreatedAt;
    searchRequest.sortAsc = 1;
    searchRequest.perPage = 50;
    searchRequest.minCreatedAt = ((UserAnnotation *)[self lastChatMessage:YES]).createdAt;
	[QBLocation geoDataWithRequest:searchRequest delegate:self];
	[searchRequest release];
}

/*
 Add new annotation to map,chat,ar
 */
- (void)createAndAddNewAnnotationToMapChatARForFBUser:(NSDictionary *)fbUser withGeoData:(QBLGeoData *)geoData addToTop:(BOOL)toTop withReloadTable:(BOOL)reloadTable{
    
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
    if(newAnnotation.qbUserID == 0){
        newAnnotation.qbUserID = geoData.userID;
    }
	newAnnotation.createdAt = geoData.createdAt;
    
    newAnnotation.distance  = [geoData.location distanceFromLocation:[[QBLLocationDataSource instance] currentLocation]];
    
    
    NSLog(@"Added message=%@", newAnnotation);
    
    
    // Add to Chat
    [self addNewMessageToChat:newAnnotation addToTop:toTop withReloadTable:reloadTable];
    
    
    // Add to Map
    [self addNewPointToMapAR:newAnnotation];
	
	[newAnnotation release];
    
    
    // update AR
    [arViewController updateMarkersPositionsForCenterLocation:arViewController.centerLocation];
}

- (void)addNewPointToMapAR:(UserAnnotation *)point{
    
    NSArray *friendsIds = [[DataManager shared].myFriendsAsDictionary allKeys];
    
    NSArray *currentMapAnnotations = [mapViewController.mapView.annotations copy];
    
    // Check for Map
    BOOL isExistPoint = NO;
    for (UserAnnotation *annotation in currentMapAnnotations)
	{
        // already exist, change status
        if([point.fbUserId isEqualToString:annotation.fbUserId])
		{
            dispatch_async( dispatch_get_main_queue(), ^{
                MapMarkerView *marker = (MapMarkerView *)[mapViewController.mapView viewForAnnotation:annotation];
                [marker updateStatus:point.userStatus];// update status
                [marker updateCoordinate:point.coordinate];
            });

            isExistPoint = YES;
            
            break;
        }
    }
    
    [currentMapAnnotations release];
    
    
    // Check for AR
    if(isExistPoint){
        
        NSArray *currentARMarkers = [arViewController.coordinateViews copy];
        
        for (ARMarkerView *marker in currentARMarkers)
		{
            // already exist, change status
            if([point.fbUserId isEqualToString:marker.userAnnotation.fbUserId])
			{
                
                dispatch_async( dispatch_get_main_queue(), ^{
                    ARMarkerView *marker = (ARMarkerView *)[arViewController viewForExistAnnotation:point];
                    [marker updateStatus:point.userStatus];// update status
                    [marker updateCoordinate:point.coordinate]; // update location  
                });
                               
                isExistPoint = YES;
                               
                break;
            }
        }
        
        [currentARMarkers release];
    }
    
    
    // new -> add to Map, AR
    if(!isExistPoint){
        BOOL addedToCurrentMapState = NO;
        
        [allMapPoints addObject:point];
        [mapPointsIDs addObject:[NSString stringWithFormat:@"%d", point.geoDataID]];
        
        if([self isAllShowed] || [friendsIds containsObject:point.fbUserId]){
            [mapPoints addObject:point];
            addedToCurrentMapState = YES;
        }
        //
        if(addedToCurrentMapState){
            dispatch_async( dispatch_get_main_queue(), ^{
                [mapViewController addPoint:point];
                [arViewController addPoint:point];
            });
        }
    }
    
    // Save to cache
    //
    [[DataManager shared] addMapARPointToStorage:point];
}

- (void)addNewMessageToChat:(UserAnnotation *)message{
    [self addNewMessageToChat:message addToTop:NO withReloadTable:NO];
}

- (void)addNewMessageToChat:(UserAnnotation *)message addToTop:(BOOL)toTop withReloadTable:(BOOL)reloadTable{
    chatViewController.messagesTableView.tag = tableIsUpdating;
    
    [chatMessagesIDs addObject:[NSString stringWithFormat:@"%d", message.geoDataID]];
    
    NSArray *friendsIds = [[DataManager shared].myFriendsAsDictionary allKeys];
    
    // Add to Chat
    BOOL addedToCurrentChatState = NO;
    
    // New messages
	if (toTop){
		[allChatPoints insertObject:message atIndex:0];
        if([self isAllShowed] || [friendsIds containsObject:message.fbUserId] ||
           [message.fbUserId isEqualToString:[DataManager shared].currentFBUserId]){
            [chatPoints insertObject:message atIndex:0];
            addedToCurrentChatState = YES;
        }
        
        // old messages
	}else {
		[allChatPoints insertObject:message atIndex:[allChatPoints count] > 0 ? ([allChatPoints count]-1) : 0];
        if([self isAllShowed] || [friendsIds containsObject:message.fbUserId] ||
           [message.fbUserId isEqualToString:[DataManager shared].currentFBUserId]){
            [chatPoints insertObject:message atIndex:[chatPoints count] > 0 ? ([chatPoints count]-1) : 0];
            addedToCurrentChatState = YES;
        }
	}
    //
    if(addedToCurrentChatState && reloadTable){
        NSIndexPath *newMessagePath = [NSIndexPath indexPathForRow:0 inSection:0];
        NSArray *newRows = [[NSArray alloc] initWithObjects:newMessagePath, nil];

        // on main thread
        dispatch_async( dispatch_get_main_queue(), ^{
            [chatViewController.messagesTableView insertRowsAtIndexPaths:newRows withRowAnimation:UITableViewRowAnimationFade];
        });
        
        [newRows release];
    }
    
    
    // Save to cache
    //
    [[DataManager shared] addChatMessageToStorage:message];
    
    chatViewController.messagesTableView.tag = 0;
}

- (void)endOfRetrieveInitialData{

    // hide wheel
    [activityIndicator removeFromSuperview];
    activityIndicator = nil;
    
    
    // start timer for check for new points
    if(updateTimre){
        [updateTimre invalidate];
        [updateTimre release];
    }
    updateTimre = [[NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForNewPoints:) userInfo:nil repeats:YES] retain];
}

#pragma mark -
#pragma mark Markers

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
    
    // is this friend?
    BOOL isThisFriend = YES;
    if(![[[DataManager shared].myFriendsAsDictionary allKeys] containsObject:selectedUserAnnotation.fbUserId]){
        isThisFriend = NO;
    }
    
    
    // show Action Sheet
    //
    // add "Quote" item only in Chat
	if (chatViewController.view.superview)
	{
        if(isThisFriend){
            userActionSheet = [[UIActionSheet alloc] initWithTitle:title 
                                                          delegate:self 
                                                 cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                            destructiveButtonTitle:nil 
                                                 otherButtonTitles:NSLocalizedString(@"Reply with quote", nil), NSLocalizedString(@"Send private FB message", nil), NSLocalizedString(@"View FB profile", nil), nil];
        }else{
            userActionSheet = [[UIActionSheet alloc] initWithTitle:title 
                                                          delegate:self 
                                                 cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                            destructiveButtonTitle:nil 
                                                 otherButtonTitles:NSLocalizedString(@"Reply with quote", nil), NSLocalizedString(@"View FB profile", nil), nil];
        }
	}
	else 
	{
        if(isThisFriend){
            userActionSheet = [[UIActionSheet alloc] initWithTitle:title 
                                                          delegate:self 
                                                 cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                            destructiveButtonTitle:nil 
                                                 otherButtonTitles:NSLocalizedString(@"Reply in public chat", nil), NSLocalizedString(@"Send private FB message", nil), NSLocalizedString(@"View FB profile", nil),
                               nil];
        }else{
            userActionSheet = [[UIActionSheet alloc] initWithTitle:title 
                                                          delegate:self 
                                                 cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                            destructiveButtonTitle:nil 
                                                 otherButtonTitles:NSLocalizedString(@"Reply in public chat", nil), NSLocalizedString(@"View FB profile", nil),
                               nil];
        }
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


#pragma mark-
#pragma mark Helpers

// convert map array of QBLGeoData objects to UserAnnotations a
- (void)processQBCheckins:(NSArray *)data{

    NSArray *fbUsers = [data objectAtIndex:0];
    NSArray *qbPoints = [data objectAtIndex:1];
    
    CLLocationCoordinate2D coordinate;
    int index = 0;
    
    NSMutableArray *mapPointsMutable = [qbPoints mutableCopy];
    
    // look through array for geodatas
    for (QBLGeoData *geodata in qbPoints)
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
        [mapPointsMutable replaceObjectAtIndex:index withObject:mapAnnotation];
        
//            // own centered
//            if([[mapAnnotation.fbUser objectForKey:kId] isEqualToString:[[DataManager shared].currentFBUser objectForKey:kId]]){
//                MKCoordinateRegion region;
//                //Set Zoom level using Span
//                MKCoordinateSpan span;
//                region.center = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
//                span.latitudeDelta = 100;
//                span.longitudeDelta = 100;
//                region.span = span;
//                [mapViewController.mapView setRegion:region animated:TRUE];
//            }
        
        [mapAnnotation release];
        
        ++index;
        
        // show Point on Map/AR
        [self addNewPointToMapAR:mapAnnotation];
    }
    
    // update AR
    dispatch_async( dispatch_get_main_queue(), ^{
        [arViewController updateMarkersPositionsForCenterLocation:arViewController.centerLocation];
    });

    //
    // add to Storage
    [[DataManager shared] addMapARPointsToStorage:mapPointsMutable];
    
    [mapPointsMutable release];
    
    // all data was retrieved
    ++self.initState;
    NSLog(@"MAP INIT OK");
    if(self.initState == 2){
        dispatch_async( dispatch_get_main_queue(), ^{
            [self endOfRetrieveInitialData];
        });
    }
}

// convert chat array of QBLGeoData objects to UserAnnotations a
- (void)processQBChatMessages:(NSArray *)data{

    NSArray *fbUsers = [data objectAtIndex:0];
    NSArray *qbMessages = [data objectAtIndex:1];

    CLLocationCoordinate2D coordinate;
    int index = 0;
    
    NSMutableArray *qbMessagesMutable = [qbMessages mutableCopy];
    
    for (QBLGeoData *geodata in qbMessages)
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
        
        [qbMessagesMutable replaceObjectAtIndex:index withObject:chatAnnotation];
        [chatAnnotation release];
        
        ++index;
        
        // show Message on Chat
        [self addNewMessageToChat:chatAnnotation addToTop:NO withReloadTable:NO];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [chatViewController.messagesTableView reloadData];
    });
    

    [qbMessagesMutable release];
    
    
    // all data was retrieved
    ++self.initState;
    NSLog(@"CHAT INIT OK");
    if(self.initState == 2){
        dispatch_async( dispatch_get_main_queue(), ^{
            [self endOfRetrieveInitialData];
        });
    }
}

// convert checkins array UserAnnotations
- (void)processFBCheckins:(NSArray *)rawCheckins{
    for(NSDictionary *checkinsResult in rawCheckins){
        if([checkinsResult isKindOfClass:NSNull.class]){
            continue;
        }
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSArray *checkins = [[parser objectWithString:(NSString *)([checkinsResult objectForKey:kBody])] objectForKey:kData];
        [parser release];
        
        if ([checkins count]){
            
            //
            
            CLLocationCoordinate2D coordinate;
            
            // Collect checkins
            NSMutableArray *proccesedCheckins = [NSMutableArray array];
            for(NSDictionary *checkin in checkins){
                
                NSString *ID = [checkin objectForKey:kId];
                if([fbCheckinsIDs containsObject:ID]){
                    continue;
                }
                
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
                checkinAnnotation.fbCheckinID = ID;
                checkinAnnotation.createdAt = createdAt;
                
                
                CLLocation *checkinLocation = [[CLLocation alloc] initWithLatitude: coordinate.latitude longitude: coordinate.longitude];
                checkinAnnotation.distance = [checkinLocation distanceFromLocation:[[QBLLocationDataSource instance] currentLocation]];
                [checkinLocation release];
                
                [proccesedCheckins addObject:checkinAnnotation];
                [checkinAnnotation release];
                
                [fbCheckinsIDs addObject:ID];
                
                
                // show Point on Map/AR
                [self addNewPointToMapAR:checkinAnnotation];
                
                // show Message on Chat
                [self addNewMessageToChat:checkinAnnotation addToTop:NO withReloadTable:NO];
            }
            
            // save Checkins
            [allCheckins addObjectsFromArray:proccesedCheckins];
            //
            // add to Storage
            [[DataManager shared] addCheckinsToStorage:proccesedCheckins];
            
        }
    }
    
    // refresh chat
    dispatch_async(dispatch_get_main_queue(), ^{
        [chatViewController.messagesTableView reloadData];
        
        [arViewController updateMarkersPositionsForCenterLocation:arViewController.centerLocation];
    });
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

// Return last chat message
- (UserAnnotation *)lastChatMessage:(BOOL)ignoreOwn{
    if(ignoreOwn){
        for(UserAnnotation *chatAnnotation in allChatPoints){
            if(![chatAnnotation.fbUserId isEqualToString:[DataManager shared].currentFBUserId]){
                return chatAnnotation;
            }
        }
    }else{
        return ((UserAnnotation *)[allChatPoints objectAtIndex:0]);
    }
    
    return nil;
}


#pragma mark -
#pragma mark Logout

- (void)logoutDone{
    isInitialized = NO;
    
    [allChatPoints removeAllObjects];
	[allCheckins removeAllObjects];
	[allMapPoints removeAllObjects];
    
    [mapPoints removeAllObjects];
    [chatPoints removeAllObjects];
    
    [chatMessagesIDs removeAllObjects];
    [mapPointsIDs removeAllObjects];
    
    [updateTimre invalidate];
    [updateTimre release];
    updateTimre = nil;
    
    
    // clean controllers
    [arViewController dissmisAR];
    [mapViewController.mapView removeAnnotations:mapViewController.mapView.annotations];
    [chatViewController.messagesTableView reloadData];
}


#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    myCurrentLocation = [newLocation retain];
    
    // update my location on server
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"Error: %@", [error description]);
}


#pragma mark -
#pragma mark FBServiceResultDelegate

-(void)completedWithFBResult:(FBServiceResult *)result context:(id)context{
    
    switch (result.queryType) {
            
        // get Users profiles
        case FBQueriesTypesUsersProfiles:{
            NSArray *contextArray = nil;
            NSString *contextType = nil;
            NSArray *points = nil;
            if([context isKindOfClass:NSArray.class]){
                contextArray = (NSArray *)context;
                
                // basic
                if(![[contextArray lastObject] isKindOfClass:QBLGeoData.class]){
                    contextType = [contextArray objectAtIndex:0];
                    points = [contextArray objectAtIndex:1];
                }// else{
                    // this is check new one
                //}
            }
            
            // Map init
            if([contextType isKindOfClass:NSString.class] && [contextType isEqualToString:mapFBUsers]){
                
                // conversation
                NSArray *data = [NSArray arrayWithObjects:[result.body allValues], points, nil];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self processQBCheckins:data];
                });
                
            // Chat init
            }else if([contextType isKindOfClass:NSString.class] && [contextType isEqualToString:chatFBUsers]){
                
                // conversation
                NSArray *data = [NSArray arrayWithObjects:[result.body allValues], points, nil];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self processQBChatMessages:data];
                });
                
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
                    [self createAndAddNewAnnotationToMapChatARForFBUser:fbUser withGeoData:geoData addToTop:YES withReloadTable:YES];
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
            
            // convert checkins
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self processFBCheckins:(NSArray *)result.body];
            });
        }
        break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark QB QBActionStatusDelegate

- (void)completedWithResult:(Result *)result context:(void *)contextInfo{
    // get points result
	if([result isKindOfClass:[QBLGeoDataPagedResult class]])
	{
        NSLog(@"QB completedWithResult, contextInfo=%@, class=%@", contextInfo, [result class]);
        
        if (result.success){
            QBLGeoDataPagedResult *geoDataSearchResult = (QBLGeoDataPagedResult *)result;
            
            // update map
            if([((NSString *)contextInfo) isEqualToString:mapSearch]){
				
                NSArray *newQBMapARPoints = [geoDataSearchResult.geodata mutableCopy];
                
                // get string of fb users ids
                NSMutableArray *fbMapUsersIds = [[NSMutableArray alloc] init];
                for (QBLGeoData *geodata in newQBMapARPoints){
                    // skip if already exist
                    if([mapPointsIDs containsObject:[NSString stringWithFormat:@"%d", geodata.ID]]){
                        continue;
                    }
                    [fbMapUsersIds addObject:geodata.user.facebookID];
                }
                if([fbMapUsersIds count] == 0){
                    return;
                }
                
                //
				NSMutableString* ids = [[NSMutableString alloc] init];
				for (NSString* userID in fbMapUsersIds)
				{
					[ids appendFormat:[NSString stringWithFormat:@"%@,", userID]];
				}
				
                
                NSArray *context = [NSArray arrayWithObjects:mapFBUsers, newQBMapARPoints, nil];
                
                
				// get FB info for obtained QB locations
				[[FBService shared] usersProfilesWithIds:[ids substringToIndex:[ids length]-1] 
                                                delegate:self 
                                                 context:context];
                
                [fbMapUsersIds release];
				[ids release];
                
            // update chat
            }else if([((NSString *)contextInfo) isEqualToString:chatSearch]){
                
                NSArray *newQBChatMesages = geoDataSearchResult.geodata;
                
                // get fb users info
                NSMutableSet *fbChatUsersIds = [[NSMutableSet alloc] init];
                for (QBLGeoData *geodata in newQBChatMesages){
                    // skip if already exist
                    if([chatMessagesIDs containsObject:[NSString stringWithFormat:@"%d", geodata.ID]]){
                        continue;
                    }
                    [fbChatUsersIds addObject:geodata.user.facebookID];
                }
                if([fbChatUsersIds count] == 0){
                    return;
                }
                
                //
                NSMutableString* ids = [[NSMutableString alloc] init];
				for (NSString* userID in fbChatUsersIds)
				{
					[ids appendFormat:[NSString stringWithFormat:@"%@,", userID]];
				}
                
                
                NSArray *context = [NSArray arrayWithObjects:chatFBUsers, newQBChatMesages, nil];
                

                // get FB info for obtained QB chat messages
				[[FBService shared] usersProfilesWithIds:[ids substringToIndex:[ids length]-1] 
                                                delegate:self 
                                                 context:context];
                [fbChatUsersIds release];
                [ids release];
            }
        
        // errors
        }else{
            [activityIndicator removeFromSuperview];
            activityIndicator = nil;
            
            NSString *message = [result.errors stringValue];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Errors", nil)
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
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
                if([chatMessagesIDs containsObject:[NSString stringWithFormat:@"%d", geodata.ID]]){
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
    int buttonsNum = actionSheet.numberOfButtons;

    switch (buttonIndex) {
        case 0:{ 

            // Reply in public chat/Reply with quote
            if(!chatViewController.view.superview){
                if (segmentControl.numberOfSegments == 2){
                    segmentControl.selectedSegmentIndex = 1;
                }else {
                    segmentControl.selectedSegmentIndex = 2;
                }
                
                [self showChat];
            }
                
            // quote action
            [chatViewController addQuote];
            [chatViewController.messageField becomeFirstResponder];
        }

            break;
            
        case 1: {
            if(buttonsNum == 3){
                // View personal FB page
                [self actionSheetViewFBProfile];
            }else{
                // Send FB message
                [self actionSheetSendPrivateFBMessage];
            }
        }
            break;

        case 2: {
            // View personal FB page
            if(buttonsNum != 3){
                [self actionSheetViewFBProfile];
            }
        }
			
            break;
            
        default:
            break;
    }
    
    [userActionSheet release];
    userActionSheet = nil;
    
    self.selectedUserAnnotation = nil;
}

- (void)actionSheetViewFBProfile{
    // View personal FB page
    
    NSString *url = [NSString stringWithFormat:@"http://www.facebook.com/profile.php?id=%@",selectedUserAnnotation.fbUserId];
    
    WebViewController *webViewControleler = [[WebViewController alloc] init];
    webViewControleler.urlAdress = url;
    [self.navigationController pushViewController:webViewControleler animated:YES];
    [webViewControleler autorelease];
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
