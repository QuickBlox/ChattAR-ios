//
//  MapViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 28/08/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "MapViewController.h"
#import "FBService.h"
#import "MapAnnotation.h"
#import "ChatRoomStorage.h"
#import "LocationService.h"
#import "ChatRoomViewController.h"
#import "MKMapView+Zoom.h"
#import "ProcessStateService.h"


@interface MapViewController ()

@end

@implementation MapViewController

- (void)dealloc
{
    QBDLogEx(@"");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mapView.mapType = MKMapTypeStandard;
    
    [Flurry logEvent:kFlurryEventMapScreenWasOpened];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // show local rooms on the map
    [self setAnnotationsToMap:[[ChatRoomStorage shared] localRooms]];
    // and zoom
    [_mapView zoomToFitAnnotations:[ChatRoomStorage shared].localRooms];
}

- (void)setAnnotationsToMap:(NSArray *)chatRooms
{
    // remove old pins
    [_mapView removeAnnotations:_mapView.annotations];
    
    NSMutableArray *_annotations = [NSMutableArray array];
    
    // add new pins
    for (QBCOCustomObject *room in chatRooms) {
        CLLocationCoordinate2D coord;
        coord.latitude = [room.fields[kLatitude] doubleValue];
        coord.longitude = [room.fields[kLongitude] doubleValue];
        
        MapAnnotation *pin = [[MapAnnotation alloc] initWithCoordinates:coord];
        pin.title = [room.fields valueForKey:kName];
        CLLocation *roomLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
        double_t distance = [[LocationService shared].myLocation distanceFromLocation:roomLocation];
        pin.subtitle = [[Utilites shared] distanceFormatter:distance];
        pin.room = room;
        
        [_annotations addObject:pin];
    }
    [_mapView addAnnotations:_annotations];
}


#pragma mark -
#pragma mark MKMapViewDelegate

- (MapAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MapAnnotation *)annotation
{
    static NSString *annotationIdentifier = @"MapAnnotationIdentifier";
    MapAnnotationView *aView = (MapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (aView == nil) {
        aView = [[MapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        [aView handleAnnotationView];

        UIButton *button = (UIButton *)[aView.rightCalloutAccessoryView viewWithTag:kAnnotationButtonTag];
        [button addTarget:self action:@selector(selectRoom) forControlEvents:UIControlEventTouchUpInside];
    }
    aView.chatRoom = annotation.room;
    
    // resest room avatar
    aView.avatar.image = [UIImage imageNamed:@"room_image@2x.png"];
    
    //set room avatar
    id imageURL = aView.chatRoom.fields[kPhoto];
    if (imageURL != nil && imageURL != [NSNull null]) {
        [aView.avatar setImageURL:[NSURL URLWithString:imageURL]];
    }
    return aView;
}

- (void)selectRoom
{
    [self performSegueWithIdentifier:@"MapToChatRoom" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MapToChatRoom"]){
        
        // pass current room to Chat Room controller
        MapAnnotation *selectedAnnotation = (MapAnnotation *)_mapView.selectedAnnotations[0];
        MapAnnotationView *selectedAnnotationView = (MapAnnotationView *)[_mapView viewForAnnotation:selectedAnnotation];
        
        ((ChatRoomViewController *)segue.destinationViewController).controllerName = @"Map";
        ((ChatRoomViewController *)segue.destinationViewController).currentChatRoom = selectedAnnotationView.chatRoom;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    double latitude = self.mapView.region.center.latitude;
	double longitude = self.mapView.region.center.longitude;
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    __block MapViewController *this = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSMutableArray *nearRooms = [[ChatRoomStorage shared] sortRooms:[ChatRoomStorage shared].allLoadedRooms
                                                    accordingToLocation:currentLocation
                                                                  limit:15];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [this setAnnotationsToMap:nearRooms];
        });
    });
}

@end