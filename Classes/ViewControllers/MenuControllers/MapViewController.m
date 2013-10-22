//
//  MapViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 28/08/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "MapViewController.h"
#import "FBService.h"
#import "CAnotation.h"
#import "ChatRoomsService.h"
#import "ChatRoomViewController.h"


@interface MapViewController ()

@property (nonatomic, strong) NSArray *chatRooms;
@property (nonatomic, strong) QBCOCustomObject *chatRoom;

@end

@implementation MapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.tag = kMapViewControllerTag;
    _mapView.mapType = MKMapTypeStandard;
}

- (void)viewWillAppear:(BOOL)animated{
    // getting local rooms:
    _chatRooms = [[ChatRoomsService shared] allLocalRooms];
    // setting local rooms at the map:
    [self setAnnotationsToMap:_chatRooms];
    [super viewWillAppear:NO];
}

-(void)setAnnotationsToMap:(NSArray *)chatRooms {
    for (QBCOCustomObject *room in self.chatRooms) {
        CLLocationCoordinate2D coord;
        coord.latitude = [[room.fields valueForKey:kLatitude] floatValue];
        coord.longitude = [[room.fields valueForKey:kLongitude] floatValue];
        CAnotation *pin = [[CAnotation alloc] initWithCoordinates:coord];
        pin.name = [room.fields valueForKey:kName];
        pin.description = [NSString stringWithFormat:@"%li visites", (long)[[room.fields valueForKey:kRank] integerValue]];
        pin.room = room;
        [_mapView addAnnotation:pin];
    }
}


#pragma mark -
#pragma mark MKMapViewDelegate

-(CAnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(CAnotation *)annotation {
    
    static NSString *annotationIdentifier = @"annotationIdentifier";
    CAnotationView *aView = (CAnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (aView == nil) {
        aView = [[CAnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
    }
    aView.centerOffset = CGPointZero;
    aView.image = [UIImage imageNamed:@"03_pin.png"];
    aView.avatar.image = [UIImage imageNamed:@"room.jpg"];
    aView.annotationTitle = annotation.name;
    aView.chatRoom = annotation.room;
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(CAnotationView *)view{
    NSLog(@"Anotation selected.");
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:view.annotationTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Connect", nil];
    _chatRoom = view.chatRoom;
    [action showInView:self.view];
}


#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self performSegueWithIdentifier:@"MapToChat" sender:_chatRoom];
            break;
            
        default:
            break;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MapToChat"]){
        // passcurrent room to Chat Room controller
        ((ChatRoomViewController *)segue.destinationViewController).currentChatRoom = sender;
    }
}


@end
