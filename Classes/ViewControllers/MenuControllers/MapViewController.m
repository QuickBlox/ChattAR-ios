//
//  MapViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 28/08/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "MapViewController.h"
#import "MapPin.h"
#import "ChatRooms.h"

@interface MapViewController ()

@property (nonatomic, strong) NSArray *chatRooms;

@end

@implementation MapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _mapView.mapType = MKMapTypeStandard;
}

- (void)viewWillAppear:(BOOL)animated{
    _chatRooms = [[ChatRooms action] getLocalRooms];
    [self setAnnotationsToMap:_chatRooms];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setAnnotationsToMap:(NSArray *)chatRooms {
    for (QBCOCustomObject *room in self.chatRooms) {
        CLLocationCoordinate2D coord;
        coord.latitude = [[room.fields valueForKey:kLatitude] floatValue];
        coord.longitude = [[room.fields valueForKey:kLongitude] floatValue];
        MapPin *pin = [[MapPin alloc] initWithCoordinates:coord];
        pin.name = [room.fields valueForKey:kName];
        pin.description = [NSString stringWithFormat:@"%li visites", (long)[[room.fields valueForKey:kRank] integerValue]];
        [_mapView addAnnotation:pin];
    }
}


#pragma mark -
#pragma mark MKMapViewDelegate

-(CAnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    static NSString *annotationIdentifier = @"annotationIdentifier";
    CAnotationView *aView = (CAnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (aView == nil) {
        aView = [[CAnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
    }
    aView.centerOffset = CGPointZero;
    aView.image = [UIImage imageNamed:@"03_pin.png"];
    aView.avatar.image = [UIImage imageNamed:@"room.jpg"];
    return aView;
}

@end
