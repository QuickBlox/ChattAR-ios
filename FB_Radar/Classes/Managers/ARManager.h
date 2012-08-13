//
//  ARManager.h
//  MashApp-location_users-ar-ios
//
//  Created by Igor Khomenko on 3/26/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#define maxARDistance 20000000

#define minARMarkerScale 0.65f
#define countOfScaledChunks 7
#define scaleStep() (1-minARMarkerScale)/countOfScaledChunks

#define minARMarkerAlpha 0.6f
#define alphaStep() (1-minARMarkerAlpha)/countOfScaledChunks

@protocol ARLocationDataSource
- (NSArray *)points; 
- (UIView *)viewForLocationPoint:(QBLGeoData *)location; 
@end


@interface ARManager : NSObject {
}

+(BOOL)deviceSupportsAR;

@end
