//
//  MapChatARViewController.h
//  Fbmsg
//
//  Created by Alexey on 21.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "ChatViewController.h"
#import "AugmentedRealityController.h"
#import "FBServiceResultDelegate.h"

#define kGetGeoDataCount 20

@class ChatViewController;
@class MapViewController;

@interface MapChatARViewController : UIViewController <ActionStatusDelegate, FBServiceResultDelegate, UIActionSheetDelegate, FBRequestDelegate, CLLocationManagerDelegate>{
    
    NSTimer *updateTimre;
    
    short numberOfCheckinsRetrieved;
    
    BOOL isInitialized;
    
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, assign) NSMutableArray* allMapPoints;
@property (nonatomic, assign) NSMutableArray* allChatPoints;
@property (nonatomic, assign) NSMutableArray* allCheckins;

@property (nonatomic, assign) NSMutableArray *mapPoints;
@property (nonatomic, assign) NSMutableArray *chatPoints;

@property (nonatomic, assign) NSMutableArray *chatMessagesIDs;
@property (nonatomic, assign) NSMutableArray *mapPointsIDs;
@property (nonatomic, assign) NSMutableArray *fbCheckinsIDs;

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) UIActionSheet *userActionSheet;

@property (nonatomic, retain) IBOutlet MapViewController *mapViewController;
@property (nonatomic, retain) IBOutlet ChatViewController *chatViewController;
@property (nonatomic, retain) AugmentedRealityController *arViewController;

@property (nonatomic, assign) UISegmentedControl *segmentControl;

@property (nonatomic, retain) UserAnnotation *selectedUserAnnotation;

@property (nonatomic, assign) BOOL initedFromCache;

@property (nonatomic, assign) CustomSwitch *allFriendsSwitch;

@property (assign) short initState; // 2 if all data(map/chat) was retrieved


- (void)segmentValueDidChanged:(id)sender;
- (void)showRadar;
- (void)showChat;
- (void)showMap;

- (void)allFriendsSwitchValueDidChanged:(id)sender;
- (BOOL)isAllShowed;

- (void)createAndAddNewAnnotationToMapChatARForFBUser:(NSDictionary *)fbUser withGeoData:(QBLGeoData *)geoData addToTop:(BOOL)toTop withReloadTable:(BOOL)reloadTable;

- (void)touchOnMarker:(UIView *)marker;
- (void)showActionSheetWithTitle:(NSString *)title andSubtitle:(NSString*)subtitle;

@end
