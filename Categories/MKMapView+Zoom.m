//
//  MKMapView+Zoom.m
//

#import "MKMapView+Zoom.h"
#import "ChatRoomStorage.h"

#define MINIMUM_MAP_ZOOM 20000

@implementation MKMapView (Zoom)

- (void)zoomToFitAnnotations:(NSArray *)annotations
{
    NSArray *rooms = annotations;
    if ([rooms count] < 1) {
        return;
    }
    
    //Set the default max and minimm coordinates, the top left of the world, and the bottom right of the world
    CLLocationCoordinate2D topLeftCoord = CLLocationCoordinate2DMake(-90, 180);
    CLLocationCoordinate2D bottomRightCoord = CLLocationCoordinate2DMake(90, -180);

    // for each annotation, decrease the top left longitude, increase the latitude
    // for each annotation, increase the bot right longitude, decrease the latitude
    int i;
    for(i=0; i<3; i++) {
        double_t roomLongitude = [((QBCOCustomObject *)rooms[i]).fields[kLongitude] doubleValue];
        double_t roomLatitude = [((QBCOCustomObject *)rooms[i]).fields[kLatitude] doubleValue];
        
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, roomLongitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, roomLatitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, roomLongitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, roomLatitude);
    }
    
    // Now we turn the Core Location Coordinates (which are real world GPS coordinates) into MKMapView points (which are points on a View)
    // An MKMapView is basically one view that is the width and height of the whole world layed flat. 
    // What we're going to do here, is take our two GPS points and turn them into a rectangle that is a portion of the whole world that we want the map to show.
    
    // Convert the two points to MKMapPoints
    MKMapPoint topLeftPoint = MKMapPointForCoordinate(topLeftCoord);
    MKMapPoint bottomRightPoint = MKMapPointForCoordinate(bottomRightCoord);
    
    // Of the two points, calculate the center point between them, this will be where our map is centered.
    MKMapPoint centrePoint = MKMapPointMake((topLeftPoint.x + bottomRightPoint.x) / 2, (topLeftPoint.y + bottomRightPoint.y) / 2);
    
    // Work out the widths between the top left and bottom right points
    double spanWidth = fabs(topLeftPoint.x - bottomRightPoint.x);
    double spanHeight = fabs(topLeftPoint.y - bottomRightPoint.y);

    // Apply the MAX macro to make sure we have at least a minimum zoom level, don't want to zoom too far in.
    double mapWidth = MAX(spanWidth, MINIMUM_MAP_ZOOM);
    double mapHeight = MAX(spanHeight, MINIMUM_MAP_ZOOM);
    
    // From our center, and widths, create a rectangle to display.
    MKMapRect mapRect;
    mapRect.origin.x = centrePoint.x - mapWidth / 2;
    mapRect.origin.y = centrePoint.y - mapHeight / 2;
    mapRect.size = MKMapSizeMake(mapWidth, mapHeight);
    
    //You can then futher padd the map, and it will return a rect that fits based on it's bounds
    MKMapRect adjustedRect = [self mapRectThatFits:mapRect edgePadding:UIEdgeInsetsMake(40.0, 40.0, 40.0, 40.0)];   // 40 40 40 40

    [self setVisibleMapRect:adjustedRect animated:YES];
}

@end
