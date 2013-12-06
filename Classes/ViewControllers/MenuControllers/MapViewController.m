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


@interface MapViewController ()

@property (nonatomic, strong) NSArray *chatRooms;
@property (nonatomic, strong) QBCOCustomObject *chatRoom;

@end

@implementation MapViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.tag = kMapViewControllerTag;
    _mapView.mapType = MKMapTypeStandard;
}

- (void)viewWillAppear:(BOOL)animated {
    // getting local rooms:
    _chatRooms = [[ChatRoomStorage shared] allLocalRooms];
    // setting local rooms at the map:
    [self setAnnotationsToMap:_chatRooms];
    [super viewWillAppear:NO];
}

- (void)setAnnotationsToMap:(NSArray *)chatRooms {
    for (QBCOCustomObject *room in self.chatRooms) {
        CLLocationCoordinate2D coord;
        coord.latitude = [room.fields[kLatitude] doubleValue];
        coord.longitude = [room.fields[kLongitude] doubleValue];
        MapAnnotation *pin = [[MapAnnotation alloc] initWithCoordinates:coord];
        pin.title = [room.fields valueForKey:kName];
        CLLocation *roomLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
        double_t distance = [[LocationService shared].myLocation distanceFromLocation:roomLocation];
        pin.subtitle = [[Utilites shared] distanceFormatter:distance];
        pin.room = room;
        [_mapView addAnnotation:pin];
    }
}


#pragma mark -
#pragma mark MKMapViewDelegate

- (MapAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MapAnnotation *)annotation {
    
    static NSString *annotationIdentifier = @"annotationIdentifier";
    MapAnnotationView *aView = (MapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (aView == nil) {
        aView = [[MapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        [aView handleAnnotationView];

        UIButton *button = (UIButton *)[aView.rightCalloutAccessoryView viewWithTag:kAnnotationButtonTag];
        [button addTarget:self action:@selector(selectRoom) forControlEvents:UIControlEventTouchUpInside];
    }
    aView.chatRoom = annotation.room;
    
    // resest room avatar
    aView.avatar.image = [UIImage imageNamed:@"room.jpg"];
    
    //set room avatar
    NSString *imageURL = aView.chatRoom.fields[kPhoto];
    if (imageURL != nil) {
        [aView.avatar setImageURL:[NSURL URLWithString:imageURL]];
    }
    
    return aView;
}

- (void)selectRoom {
    [self performSegueWithIdentifier:@"MapToChatRoom" sender:self.chatRoom];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MapAnnotationView *)view {
    NSLog(@"Anotation selected.");
    self.chatRoom = view.chatRoom;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MapToChatRoom"]){
        // passcurrent room to Chat Room controller
        ((ChatRoomViewController *)segue.destinationViewController).currentChatRoom = sender;
    }
}


@end