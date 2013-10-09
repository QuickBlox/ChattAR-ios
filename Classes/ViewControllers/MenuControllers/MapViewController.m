//
//  MapViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 28/08/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "MapViewController.h"
#import "FBService.h"
#import "MapPin.h"
#import "ChatRoomsService.h"


@interface MapViewController ()

@property (nonatomic, strong) NSArray *chatRooms;
@property (nonatomic, strong) NSString *roomName;

@end

@implementation MapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.tag = kMapViewControllerTag;
    _mapView.mapType = MKMapTypeStandard;
}

- (void)viewWillAppear:(BOOL)animated{
    // set status bar to black:
    //[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    // getting local rooms:
    _chatRooms = [[ChatRoomsService shared] allLocalRooms];
    // setting local rooms at the map:
    [self setAnnotationsToMap:_chatRooms];
    [super viewWillAppear:NO];
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

-(CAnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MapPin *)annotation {
    
    static NSString *annotationIdentifier = @"annotationIdentifier";
    CAnotationView *aView = (CAnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (aView == nil) {
        aView = [[CAnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
    }
    aView.centerOffset = CGPointZero;
    aView.image = [UIImage imageNamed:@"03_pin.png"];
    aView.avatar.image = [UIImage imageNamed:@"room.jpg"];
    aView.annotationTitle = annotation.name;
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(CAnotationView *)view{
    NSLog(@"Anotation selected.");
    self.roomName = view.annotationTitle;
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:self.roomName delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Connect", nil];
    [action showInView:self.view];
}


#pragma mark -
#pragma mark SASlideMenuDataSource

-(void) configureMenuButton:(UIButton *)menuButton{
    menuButton.frame = CGRectMake(0, 0, 40, 29);
    [menuButton setImage:[UIImage imageNamed:@"menu_btn_b.png"] forState:UIControlStateNormal];
    [menuButton setBackgroundColor:[UIColor clearColor]];
}


#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
//            [FBService shared].roomName = self.roomName;
            [self performSegueWithIdentifier:@"MapToChat" sender:self];
            break;
            
        default:
            break;
    }
}


@end
