//
//  AsyncImageView.m
//  FB_Radar
//
//  Created by Sonny Black on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AsyncImageView.h"
#import "ImageCacheObject.h"
#import "ImageCache.h"

static ImageCache *imageCache = nil;

@implementation AsyncImageView

@synthesize typeCrop, useMask;
@synthesize linkedUrl;

+ (void)clearCache{
    [imageCache clearCache];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (id)init{
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [connection cancel];
    [connection release];
    [data release];
    [linkedUrl release];
	
    [super dealloc];
}


-(void)loadImageFromURL:(NSURL*)url {
    if (connection != nil) {
        [connection cancel];
        [connection release];
        connection = nil;
    }
    if (data != nil) {
        [data release];
        data = nil;
    }
    
    if (imageCache == nil) {// lazily create image cache
        imageCache = [[ImageCache alloc] initWithMaxSize:2*1024*1024];  // 2 MB Image cache
    }
    
    [urlString release];
    urlString = [[url absoluteString] copy];
    
    
    // check cashed
    UIImage *cachedImage = [imageCache imageForKey:urlString];
    if (cachedImage != nil) {
        [self remakeImage:cachedImage];
        return;
    }
    
    // add temp pic
    [self setImage:[UIImage imageNamed:@"camera.png"]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url 
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                         timeoutInterval:60.0];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection 
    didReceiveData:(NSData *)incrementalData {
    if (data==nil) {
        data = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [data appendData:incrementalData];
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage; 
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    CGImageRelease(mask);
	
    UIImage *img = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
	
    return img;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    [connection release];
    connection = nil;
    
    // get image
    UIImage *imageS = [UIImage imageWithData:data];
	
    [imageCache insertImage:imageS withSize:[data length] forKey:urlString];
    
    [self remakeImage:imageS];
    
    [data release];
    data = nil;
}

- (void)remakeImage:(UIImage *)img {
    switch (typeCrop) {
        case AsyncImageCropLong: 
        {
            CGRect cropRect = CGRectMake(img.size.width/2 - self.frame.size.width/2, 0, self.frame.size.width, self.frame.size.height);
            CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], cropRect);
            // or use the UIImage wherever you like
            img = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef); 
        }
            break;
        case AsyncImageCropNone:
            
            break;
            
        default:
            break;
    }
	
    // set image
    if(useMask){
        // with mask
        UIImage *image = [self maskImage:img withMask:[UIImage imageNamed:@"AvatarMask.png"]];
        self.image = image;
        
    }else{
        self.image = img;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(linkedUrl){
        [[UIApplication sharedApplication] openURL:linkedUrl];
    }else{
        [super touchesEnded:touches withEvent:event];
    }
}

@end
