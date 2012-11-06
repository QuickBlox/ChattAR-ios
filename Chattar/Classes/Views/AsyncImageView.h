//
//  AsyncImageView.h
//  FB_Radar
//
//  Created by Sonny Black on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    AsyncImageCropNone,
    AsyncImageCropLong,
} AsyncImageCrop;

@interface AsyncImageView : UIImageView {
    NSURLConnection *connection;
    NSMutableData *data;
    NSString *urlString; // key for image cache dictionary
    
    UIImage *cachedImage;
}
@property (assign) BOOL useMask;
@property (retain) NSURL *linkedUrl;
@property (nonatomic, retain) UIImage *cachedImage;

-(void)loadImageFromURL:(NSURL*)url;
-(void)remakeImage:(UIImage *)img;

+ (void)clearCache;

@property AsyncImageCrop typeCrop;

@end
