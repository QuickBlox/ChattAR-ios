//
//  MapViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 28/08/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "MapViewController.h"
#import "MapPin.h"

@interface MapViewController ()

@property (nonatomic, strong) NSArray *chatRooms;

@end

@implementation MapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MKUserTrackingModeFollow;
    _mapView.mapType = MKMapTypeStandard;
	// Do any additional setup after loading the view.
    [QBCustomObjects objectsWithClassName:kChatRoom delegate:self];
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
#pragma mark QBActionStatusDelegate

-(void)completedWithResult:(Result *)result{
    if ([result success]) {
        if ([result isKindOfClass:[QBCOCustomObjectPagedResult class]]) {
            QBCOCustomObjectPagedResult *customObjcects = (QBCOCustomObjectPagedResult *)result;
            _chatRooms = customObjcects.objects;
            [self setAnnotationsToMap:_chatRooms];
        }
    }
}


#pragma mark -
#pragma mark MKMapViewDelegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    static NSString *annotationIdentifier = @"annotationIdentifier";
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (aView == nil) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
    }
    aView.image = [UIImage imageNamed:@"03_pin.png"];
    return aView;
}

@end
