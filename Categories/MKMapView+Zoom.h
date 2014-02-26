//
//  MKMapView+Zoom.h
//

#import <MapKit/MapKit.h>

@interface MKMapView (Zoom)

- (void)zoomToFitAnnotations:(NSArray *)annotations;

@end
