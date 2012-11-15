//
//  MapChatARViewController.m
//  ChattAR for Facebook
//
//  Created by Alexey on 21.03.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
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

#import "JSON.h"

@interface MapChatARViewController ()

- (UserAnnotation *)lastChatMessage:(BOOL)ignoreOwn;

- (void)processQBCheckins:(NSArray *)data;
- (void)processQBChatMessages:(NSArray *)data;
- (void)processFBCheckins:(NSArray *)data;

- (void)addNewPointToMapAR:(UserAnnotation *)point isFBCheckin:(BOOL)isFBCheckin;
- (void)addNewMessageToChat:(UserAnnotation *)message addToTop:(BOOL)toTop withReloadTable:(BOOL)reloadTable isFBCheckin:(BOOL)isFBCheckin;

@end

@implementation MapChatARViewController

@synthesize mapViewController, chatViewController, arViewController;
@synthesize segmentControl;
@synthesize mapPoints, chatPoints;
@synthesize chatMessagesIDs, mapPointsIDs;
@synthesize userActionSheet, allMapPoints, allCheckins, allChatPoints;
@synthesize selectedUserAnnotation;
@synthesize locationManager;
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
        

        // Loc manager
		locationManager = [[CLLocationManager alloc] init];
        [locationManager startUpdatingLocation];
		
        
        isInitialized = NO;
        
        
        // logout
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutDone) name:kNotificationLogout object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    dispatch_release(processCheckinsQueue);
    
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
    
    [userActionSheet release];
	
	[locationManager release];
    
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
    
    if(IS_HEIGHT_GTE_568){
        [allFriendsSwitch setCenter:CGPointMake(280, 448)];
    }else{
        [allFriendsSwitch setCenter:CGPointMake(280, 360)];
    }
    
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
        numberOfCheckinsRetrieved = ceil([[[DataManager shared].myPopularFriends allObjects] count]/fmaxRequestsInBatch);
        NSLog(@"Checkins Parts=%d", numberOfCheckinsRetrieved);
        [self getFBCheckins];
        

        isInitialized = YES;
        
        
        // show Alert with info at startapp
        if([[DataManager shared] isFirstStartApp]){
            [[DataManager shared] setFirstStartApp:NO];
            
            NSString *alertBody = nil;
            if([ARManager deviceSupportsAR]){
                alertBody = NSLocalizedString(@"You can see and chat with all\nusers within 10km. Increase\nsearch radius using slider (left). \nSwitch to 'Facebook only' mode (bottom right) to see your friends and their check-ins only.", nil);
                
            }else{
                alertBody = NSLocalizedString(@"Switch to 'Facebook only' mode (bottom right) to see your friends and their check-ins only.", nil);
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"'World' mode", nil)
                                                            message:alertBody
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
        if(IS_HEIGHT_GTE_568){
            [arViewController.view setFrame:CGRectMake(0, 0, 320, 475)];
        }else{
            //[arViewController.view setFrame:CGRectMake(0, 0, 320, 462)];
            [arViewController.view setFrame:CGRectMake(0, 0, 320, 387)];
        }
    
    }
    [mapViewController.view removeFromSuperview];
    [chatViewController.view removeFromSuperview];
    
    // start AR
    [arViewController displayAR];
}

- (void)showChat{
	
    if([chatViewController.view superview] == nil){
        [self.view addSubview:chatViewController.view];
//        [chatViewController.view setFrame:CGRectMake(0, 0, 320, 387)];
    }
    [mapViewController.view removeFromSuperview];
    [arViewController.view removeFromSuperview];
    
    // stop AR
    [arViewController dissmisAR];
}

- (void)showMap{
	
    if([mapViewController.view superview] == nil){
        [self.view addSubview:mapViewController.view];
//        [mapViewController.view setFrame:CGRectMake(0, 0, 320, 462)];
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
    [self.mapPoints removeAllObjects];
    //
    // 1. add All from QB
    NSMutableArray *friendsIdsWhoAlreadyAdded = [NSMutableArray array];
    for(UserAnnotation *mapAnnotation in self.allMapPoints){
        [self.mapPoints addObject:mapAnnotation];
        [friendsIdsWhoAlreadyAdded addObject:mapAnnotation.fbUserId];
    }
    //
    // add checkin
    NSArray *allCheckinsCopy = [self.allCheckins copy];
    for (UserAnnotation* checkin in allCheckinsCopy){
        if (![friendsIdsWhoAlreadyAdded containsObject:checkin.fbUserId]){
            [self.mapPoints addObject:checkin];
            [friendsIdsWhoAlreadyAdded addObject:checkin.fbUserId];
        }else{
            // compare datetimes - add newest
            NSDate *newCreateDateTime = checkin.createdAt;
            
            int index = [friendsIdsWhoAlreadyAdded indexOfObject:checkin.fbUserId];
            NSDate *currentCreateDateTime = ((UserAnnotation *)[self.mapPoints objectAtIndex:index]).createdAt;
            
            if([newCreateDateTime compare:currentCreateDateTime] == NSOrderedDescending){ //The receiver(newCreateDateTime) is later in time than anotherDate, NSOrderedDescending
                [self.mapPoints replaceObjectAtIndex:index withObject:checkin];
                [friendsIdsWhoAlreadyAdded replaceObjectAtIndex:index withObject:checkin.fbUserId];
            }
        }
    }
    [allCheckinsCopy release];
    
    
    // Chat points
    //
    [self.chatPoints removeAllObjects];
    //
    // 2. add Friends from FB
    [self.chatPoints addObjectsFromArray:self.allChatPoints];
    //
    // add all checkins
    for(UserAnnotation *checkinAnnotatin in self.allCheckins){
        if(![self.chatPoints containsObject:checkinAnnotatin]){
            [self.chatPoints addObject:checkinAnnotatin];
        }
    }
    
    
    
    // notify controllers
    [mapViewController refreshWithNewPoints:self.mapPoints];
    [arViewController refreshWithNewPoints:self.mapPoints];
    [chatViewController refresh];
}

- (void) showFriends{
    NSMutableArray *friendsIds = [[[DataManager shared].myFriendsAsDictionary allKeys] mutableCopy];
    [friendsIds addObject:[DataManager shared].currentFBUserId];// add me
    
    // Map/AR points
    //
    [self.mapPoints removeAllObjects];
    //
    // add only friends QB points
    NSMutableArray *friendsIdsWhoAlreadyAdded = [NSMutableArray array];
    for(UserAnnotation *mapAnnotation in self.allMapPoints){
        if([friendsIds containsObject:[mapAnnotation.fbUser objectForKey:kId]]){
            [self.mapPoints addObject:mapAnnotation];
            
            [friendsIdsWhoAlreadyAdded addObject:[mapAnnotation.fbUser objectForKey:kId]];
        }
    }
    //
    // add checkin
    NSArray *allCheckinsCopy = [self.allCheckins copy];
    for (UserAnnotation* checkin in allCheckinsCopy){
        if (![friendsIdsWhoAlreadyAdded containsObject:checkin.fbUserId]){
            [self.mapPoints addObject:checkin];
            [friendsIdsWhoAlreadyAdded addObject:checkin.fbUserId];
        }else{
            // compare datetimes - add newest
            NSDate *newCreateDateTime = checkin.createdAt;
            
            int index = [friendsIdsWhoAlreadyAdded indexOfObject:checkin.fbUserId];
            NSDate *currentCreateDateTime = ((UserAnnotation *)[self.mapPoints objectAtIndex:index]).createdAt;
            
            if([newCreateDateTime compare:currentCreateDateTime] == NSOrderedDescending){ //The receiver(newCreateDateTime) is later in time than anotherDate, NSOrderedDescending
                [self.mapPoints replaceObjectAtIndex:index withObject:checkin];
                [friendsIdsWhoAlreadyAdded replaceObjectAtIndex:index withObject:checkin.fbUserId];
            }
        }
    }
    [allCheckinsCopy release];
    
    
    // Chat points
    //
    [self.chatPoints removeAllObjects];
    //
    // add only friends QB points
    for(UserAnnotation *mapAnnotation in self.allChatPoints){
        if([friendsIds containsObject:[mapAnnotation.fbUser objectForKey:kId]]){
            [self.chatPoints addObject:mapAnnotation];
        }
    }
    [friendsIds release];
    //
    // add all checkins
    for(UserAnnotation *checkinAnnotatin in self.allCheckins){
        if(![self.chatPoints containsObject:checkinAnnotatin]){
            [self.chatPoints addObject:checkinAnnotatin];
        }
    }
    
    [mapViewController refreshWithNewPoints:self.mapPoints];
    [arViewController refreshWithNewPoints:self.mapPoints];
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
            [self.allChatPoints addObject:chatCashedMessage.body];
            [self.chatMessagesIDs addObject:[NSString stringWithFormat:@"%d", ((UserAnnotation *)chatCashedMessage.body).geoDataID]];
        }
    }
    
    // get map/ar points from cash
    NSDate *lastPointDate = nil;
    NSArray *cashedMapARPoints = [[DataManager shared] mapARPointsFromStorage];
    if([cashedMapARPoints count] > 0){
        for(QBCheckinModel *mapARCashedPoint in cashedMapARPoints){
            if(lastPointDate == nil){
                lastPointDate = ((UserAnnotation *)mapARCashedPoint.body).createdAt;
            }
            [self.allMapPoints addObject:mapARCashedPoint.body];
            [self.mapPointsIDs addObject:[NSString stringWithFormat:@"%d", ((UserAnnotation *)mapARCashedPoint.body).geoDataID]];
        }
    }
    
    // If we have info from cashe - show them
    if([self.allMapPoints count] > 0 || [self.allChatPoints count] > 0){
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
            [self.allCheckins addObject:checkinCashedPoint.body];
        }
    }
    
    if([self.allCheckins count] > 0){
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
    
    newAnnotation.distance  = [geoData.location distanceFromLocation:self.locationManager.location];
    
    
    // Add to Chat
    [self addNewMessageToChat:newAnnotation addToTop:toTop withReloadTable:reloadTable isFBCheckin:NO];
    
    
    // Add to Map
    [self addNewPointToMapAR:newAnnotation isFBCheckin:NO];
	
	[newAnnotation release];
    
    
    // update AR
    [arViewController updateMarkersPositionsForCenterLocation:arViewController.centerLocation];
}

- (void)addNewPointToMapAR:(UserAnnotation *)point isFBCheckin:(BOOL)isFBCheckin{
    
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
        __block BOOL addedToCurrentMapState = NO;
        
        dispatch_async( dispatch_get_main_queue(), ^{
        
            [self.allMapPoints addObject:point];
            
            if(point.geoDataID != -1){
                [self.mapPointsIDs addObject:[NSString stringWithFormat:@"%d", point.geoDataID]];
            }
            
            if([self isAllShowed] || [friendsIds containsObject:point.fbUserId]){
                [self.mapPoints addObject:point];
                addedToCurrentMapState = YES;
            }
            //
            if(addedToCurrentMapState){
                
                    [mapViewController addPoint:point];
                    [arViewController addPoint:point];
      
            }
            
        });
    }
    
    // Save to cache
    //
    if(!isFBCheckin){
        [[DataManager shared] addMapARPointToStorage:point];
    }
}

- (void)addNewMessageToChat:(UserAnnotation *)message addToTop:(BOOL)toTop withReloadTable:(BOOL)reloadTable isFBCheckin:(BOOL)isFBCheckin{
    chatViewController.messagesTableView.tag = tableIsUpdating;
    
    if(message.geoDataID != -1){
        [self.chatMessagesIDs addObject:[NSString stringWithFormat:@"%d", message.geoDataID]];
    }
    
    NSArray *friendsIds = [[DataManager shared].myFriendsAsDictionary allKeys];
    
    // Add to Chat
    __block BOOL addedToCurrentChatState = NO;
    
    dispatch_async( dispatch_get_main_queue(), ^{
    
        // New messages
        if (toTop){
            [self.allChatPoints insertObject:message atIndex:0];
            if([self isAllShowed] || [friendsIds containsObject:message.fbUserId] ||
               [message.fbUserId isEqualToString:[DataManager shared].currentFBUserId]){
                [self.chatPoints insertObject:message atIndex:0];
                addedToCurrentChatState = YES;
            }
            
        // old messages
        }else {
            [self.allChatPoints insertObject:message atIndex:[self.allChatPoints count] > 0 ? ([self.allChatPoints count]-1) : 0];
            if([self isAllShowed] || [friendsIds containsObject:message.fbUserId] ||
               [message.fbUserId isEqualToString:[DataManager shared].currentFBUserId]){
                [self.chatPoints insertObject:message atIndex:[self.chatPoints count] > 0 ? ([self.chatPoints count]-1) : 0];
                addedToCurrentChatState = YES;
            }
        }
        //
        if(addedToCurrentChatState && reloadTable){
            // on main thread
            
                [chatViewController.messagesTableView reloadData];
         
        }
    });
    
    
    
    // Save to cache
    //
    if(!isFBCheckin){
        [[DataManager shared] addChatMessageToStorage:message];
    }
    
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
        self.selectedUserAnnotation = [self.chatPoints objectAtIndex:marker.tag];
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
            NSString *ID = [user objectForKey:kId];
            if([geodata.user.facebookID isEqualToString:ID]){
                fbUser = user;
                break;
            }
        }
        
        if ([geodata.user.facebookID isEqualToString:[DataManager shared].currentFBUserId])
        {
            coordinate.latitude = self.locationManager.location.coordinate.latitude;
            coordinate.longitude = self.locationManager.location.coordinate.longitude;
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
        [mapAnnotation release];
        
        ++index;
        
        // show Point on Map/AR
        [self addNewPointToMapAR:mapAnnotation isFBCheckin:NO];
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
    
    for (QBLGeoData *geodata in qbMessages){
        NSDictionary *fbUser = nil;
        for(NSDictionary *user in fbUsers){
            NSString *ID = [user objectForKey:kId];                                  
            if([geodata.user.facebookID isEqualToString:ID]){
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
        
        chatAnnotation.distance  = [geodata.location distanceFromLocation:self.locationManager.location];
        
        [qbMessagesMutable replaceObjectAtIndex:index withObject:chatAnnotation];
        [chatAnnotation release];
        
        ++index;
        
        // show Message on Chat
        [self addNewMessageToChat:chatAnnotation addToTop:NO withReloadTable:NO isFBCheckin:NO];
    }
    
    NSLog(@"CHAT INIT reloadData");
    dispatch_async(dispatch_get_main_queue(), ^{
         [chatViewController refresh];
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
    if([rawCheckins isKindOfClass:NSString.class]){
        NSLog(@"rawCheckins=%@", rawCheckins);
#ifdef DEBUG
        id exc = [NSException exceptionWithName:NSInvalidArchiveOperationException
                                         reason:@"rawCheckins = NSString"
                                       userInfo:nil];
        @throw exc;
#endif
        return;
    }
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
            //
            NSString *previousPlaceID = nil;
            NSString *previousFBUserID = nil;
            
            // Collect checkins
            for(NSDictionary *checkin in checkins){
                
                NSString *ID = [checkin objectForKey:kId];
                
                NSDictionary *place = [checkin objectForKey:kPlace];
                if(place == nil){
                    continue;
                }
                
                id location = [place objectForKey:kLocation];
                if(![location isKindOfClass:NSDictionary.class]){
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
                
                // coordinate
                coordinate.latitude = [[[place objectForKey:kLocation] objectForKey:kLatitude] floatValue];
                coordinate.longitude = [[[place objectForKey:kLocation] objectForKey:kLongitude] floatValue];
                
                
                // if this is checkin on the same location 
                if([previousPlaceID isEqualToString:[place objectForKey:kId]] && [previousFBUserID isEqualToString:fbUserID]){
                    continue;
                }
                
                
                // status
                NSString *status = nil;
                NSString* country = [location objectForKey:kCountry];
    
                
                NSString* city = [location objectForKey:kCity];
                
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
                
                UserAnnotation *checkinAnnotation = [[UserAnnotation alloc] init];
                checkinAnnotation.geoDataID = -1;
                checkinAnnotation.coordinate = coordinate;
                checkinAnnotation.userStatus = status;
                checkinAnnotation.userName = [[checkin objectForKey:kFrom] objectForKey:kName];
                checkinAnnotation.userPhotoUrl = [fbUser objectForKey:kPicture];
                checkinAnnotation.fbUserId = [fbUser objectForKey:kId];
                checkinAnnotation.fbUser = fbUser;
                checkinAnnotation.fbCheckinID = ID;
                checkinAnnotation.fbPlaceID = [place objectForKey:kId];
                checkinAnnotation.createdAt = createdAt;
                
                
                CLLocation *checkinLocation = [[CLLocation alloc] initWithLatitude: coordinate.latitude longitude: coordinate.longitude];
                checkinAnnotation.distance = [checkinLocation distanceFromLocation:self.locationManager.location];
                [checkinLocation release];
                
                // add to Storage
                BOOL isAdded = [[DataManager shared] addCheckinToStorage:checkinAnnotation];
                if(!isAdded){
                    [checkinAnnotation release];
                    continue;
                }

                // show Point on Map/AR
                [self addNewPointToMapAR:checkinAnnotation isFBCheckin:YES];

                // show Message on Chat
                UserAnnotation *chatAnnotation = [checkinAnnotation copy];
                
                [self addNewMessageToChat:chatAnnotation addToTop:NO withReloadTable:NO isFBCheckin:YES];
                
                previousPlaceID = [place objectForKey:kId];
                previousFBUserID = fbUserID;
                
                [self.allCheckins addObject:chatAnnotation];
                [checkinAnnotation release];
                [chatAnnotation release];
            }
        }
    }
    
    if(numberOfCheckinsRetrieved == 0){
        NSLog(@"Checkins have procceced");
    }
    
    // refresh chat
    dispatch_async(dispatch_get_main_queue(), ^{
        [chatViewController refresh];
        
        [arViewController updateMarkersPositionsForCenterLocation:arViewController.centerLocation];
    });
}

// Add Quote data to annotation
- (void)addQuoteDataToAnnotation:(UserAnnotation *)annotation geoData:(QBLGeoData *)geoData{
    // get quoted geodata
    annotation.userStatus = [geoData.status substringFromIndex:[geoData.status rangeOfString:quoteDelimiter].location+1];
    
    // Author FB id
    NSString* authorFBId = [[geoData.status substringFromIndex:6] substringToIndex:[geoData.status rangeOfString:nameIdentifier].location-6];
    annotation.quotedUserFBId = authorFBId;
    
    // Author name
    NSString* authorName = [[geoData.status substringFromIndex:[geoData.status rangeOfString:nameIdentifier].location+6] substringToIndex:[[geoData.status substringFromIndex:[geoData.status rangeOfString:nameIdentifier].location+6] rangeOfString:dateIdentifier].location];
    annotation.quotedUserName = authorName;
    
    // origin Message date
    NSString* date = [[geoData.status substringFromIndex:[geoData.status rangeOfString:dateIdentifier].location+6] substringToIndex:[[geoData.status substringFromIndex:[geoData.status rangeOfString:dateIdentifier].location+6] rangeOfString:photoIdentifier].location];
    //
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss Z"];
    annotation.quotedMessageDate = [formatter dateFromString:date];
    [formatter release];
    
    // authore photo
    NSString* photoLink = [[geoData.status substringFromIndex:[geoData.status rangeOfString:photoIdentifier].location+7] substringToIndex:[[geoData.status substringFromIndex:[geoData.status rangeOfString:photoIdentifier].location+7] rangeOfString:qbidIdentifier].location];
    annotation.quotedUserPhotoURL = photoLink;
    
    // Authore QB id
    NSString* authorQBId = [[geoData.status substringFromIndex:[geoData.status rangeOfString:qbidIdentifier].location+6] substringToIndex:[[geoData.status substringFromIndex:[geoData.status rangeOfString:qbidIdentifier].location+6] rangeOfString:messageIdentifier].location];
    annotation.quotedUserQBId = authorQBId;
    
    // origin message
    NSString* message = [[geoData.status substringFromIndex:[geoData.status rangeOfString:messageIdentifier].location+5] substringToIndex:[[geoData.status substringFromIndex:[geoData.status rangeOfString:messageIdentifier].location+5] rangeOfString:quoteDelimiter].location];
    annotation.quotedMessageText = message;
}

// Return last chat message
- (UserAnnotation *)lastChatMessage:(BOOL)ignoreOwn{
    if(ignoreOwn){
        for(UserAnnotation *chatAnnotation in self.chatPoints){
            if(![chatAnnotation.fbUserId isEqualToString:[DataManager shared].currentFBUserId]){
                return chatAnnotation;
            }
        }
    }else{
        return ((UserAnnotation *)[self.chatPoints objectAtIndex:0]);
    }
    
    return nil;
}


#pragma mark -
#pragma mark Logout

- (void)logoutDone{
    isInitialized = NO;
    
    [self.allChatPoints removeAllObjects];
	[self.allCheckins removeAllObjects];
	[self.allMapPoints removeAllObjects];
    
    [self.mapPoints removeAllObjects];
    [self.chatPoints removeAllObjects];
    
    [self.chatMessagesIDs removeAllObjects];
    [self.mapPointsIDs removeAllObjects];
    
    [updateTimre invalidate];
    [updateTimre release];
    updateTimre = nil;
    
    
    // clean controllers
    [arViewController dissmisAR];
    [arViewController clear];
    [mapViewController clear];
    [chatViewController.messagesTableView reloadData];
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
                
                if([result.body isKindOfClass:NSDictionary.class]){
                    NSDictionary *resultError = [result.body objectForKey:kError];
                    if(resultError != nil){
                        // all data was retrieved
                        ++self.initState;
                        NSLog(@"MAP INIT FB ERROR");
                        if(self.initState == 2){
                            [self endOfRetrieveInitialData];
                        }
                        return;
                    }
                
                    // conversation
                    NSArray *data = [NSArray arrayWithObjects:[result.body allValues], points, nil];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [self processQBCheckins:data];
                    });
                
                // Undefined format
                }else{
                    ++self.initState;
                    NSLog(@"MAP INIT FB Undefined format");
                    if(self.initState == 2){
                        [self endOfRetrieveInitialData];
                    }
                }
                
            // Chat init
            }else if([contextType isKindOfClass:NSString.class] && [contextType isEqualToString:chatFBUsers]){
                
                if([result.body isKindOfClass:NSDictionary.class]){
                    NSDictionary *resultError = [result.body objectForKey:kError];
                    if(resultError != nil){
                        // all data was retrieved
                        ++self.initState;
                        NSLog(@"CHAT INIT FB ERROR");
                        if(self.initState == 2){
                            [self endOfRetrieveInitialData];
                        }
                        return;
                    }

                    // conversation
                    NSArray *data = [NSArray arrayWithObjects:[result.body allValues], points, nil]; 
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [self processQBChatMessages:data];
                    });
                
                // Undefined format
                }else{
                    ++self.initState;
                    NSLog(@"CHAT INIT FB Undefined format");
                    if(self.initState == 2){
                        [self endOfRetrieveInitialData];
                    }
                }
                
            // check new one
            }else{
                
                if([result.body isKindOfClass:NSDictionary.class]){
                    NSDictionary *resultError = [result.body objectForKey:kError];
                    if(resultError != nil){
                        NSLog(@"check new one FB ERROR");
                        return;
                    }

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
                
                // Undefined format
                }else{
                   // ... 
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
            
            // if error, return.
            // for example:
            // {
            // "error": {
            //    "message": "Invalid OAuth access token.",
            //    "type": "OAuthException",
            //    "code": 190
            // }
            if([result.body isKindOfClass:NSDictionary.class]){
                NSDictionary *resultError = [result.body objectForKey:kError];
                if(resultError != nil){
                    NSLog(@"resultError=%@", resultError);
                    return;
                }
            }
            
            if(processCheckinsQueue == NULL){
                processCheckinsQueue = dispatch_queue_create("com.quickblox.chattar.process.checkins.queue", NULL);  
            }
            
            if([result.body isKindOfClass:NSArray.class]){
                // convert checkins
                dispatch_async(processCheckinsQueue, ^{
                    [self processFBCheckins:(NSArray *)result.body];
                });
            }
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

                // get string of fb users ids
                NSMutableArray *fbMapUsersIds = [[NSMutableArray alloc] init];
                NSMutableArray *geodataProcessed = [NSMutableArray array];
                
                for (QBLGeoData *geodata in geoDataSearchResult.geodata){
                    // skip if already exist
                    if([self.mapPointsIDs containsObject:[NSString stringWithFormat:@"%d", geodata.ID]]){
                        continue;
                    }
                    
                    //add users with only nonzero coordinates
                    if(geodata.latitude != 0 && geodata.longitude != 0){
                        [fbMapUsersIds addObject:geodata.user.facebookID];
                    
                        [geodataProcessed addObject:geodata];
                    }
                }
                if([fbMapUsersIds count] == 0){
                    [fbMapUsersIds release];
                    return;
                }
                
                //
				NSMutableString* ids = [[NSMutableString alloc] init];
				for (NSString* userID in fbMapUsersIds)
				{
					[ids appendFormat:[NSString stringWithFormat:@"%@,", userID]];
				}
				
                NSLog(@"ids=%@", ids);
                
                NSArray *context = [NSArray arrayWithObjects:mapFBUsers, geodataProcessed, nil];
                
                
				// get FB info for obtained QB locations
				[[FBService shared] usersProfilesWithIds:[ids substringToIndex:[ids length]-1] 
                                                delegate:self 
                                                 context:context];
                
                [fbMapUsersIds release];
				[ids release];
                
            // update chat
            }else if([((NSString *)contextInfo) isEqualToString:chatSearch]){
                
                // get fb users info
                NSMutableSet *fbChatUsersIds = [[NSMutableSet alloc] init];
                
                NSMutableArray *geodataProcessed = [NSMutableArray array];
                
                for (QBLGeoData *geodata in geoDataSearchResult.geodata){
                    // skip if already exist
                    if([self.chatMessagesIDs containsObject:[NSString stringWithFormat:@"%d", geodata.ID]]){
                        continue;
                    }
                    [fbChatUsersIds addObject:geodata.user.facebookID];
                    
                    [geodataProcessed addObject:geodata];
                }
                if([fbChatUsersIds count] == 0){
                    [fbChatUsersIds release];
                    return;
                }
                
                //
                NSMutableString* ids = [[NSMutableString alloc] init];
				for (NSString* userID in fbChatUsersIds)
				{
					[ids appendFormat:[NSString stringWithFormat:@"%@,", userID]];
				}
                
                
                NSArray *context = [NSArray arrayWithObjects:chatFBUsers, geodataProcessed, nil];
                

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
        }
    }
}

- (void)completedWithResult:(Result *)result {
    NSLog(@"completedWithResult");
    
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
                if([self.chatMessagesIDs containsObject:[NSString stringWithFormat:@"%d", geodata.ID]]){
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
                
                //add users with only nonzero coordinates
                if(geodata.longitude != 0 && geodata.latitude != 0){
                    [geodataProcessed addObject:geodata];
                }
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
                
                // move wheel to front
                if(activityIndicator){
                    [self.view bringSubviewToFront:activityIndicator];
                }
                //
                // move all/friends switch to front
                [self.view bringSubviewToFront:allFriendsSwitch];
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
