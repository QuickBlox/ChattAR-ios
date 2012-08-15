//
//  ImageCache.h
//  FB_Radar
//
//  Created by Sonny Black on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageCacheObject;

@interface ImageCache : NSObject {
    NSUInteger totalSize;  // total number of bytes
    NSUInteger maxSize;    // maximum capacity
    NSMutableDictionary *myDictionary;
}

@property (nonatomic, readonly) NSUInteger totalSize;

-(id)initWithMaxSize:(NSUInteger) max;
-(void)insertImage:(UIImage*)image withSize:(NSUInteger)sz forKey:(NSString*)key;
-(UIImage*)imageForKey:(NSString*)key;

- (void) clearCache;

@end
