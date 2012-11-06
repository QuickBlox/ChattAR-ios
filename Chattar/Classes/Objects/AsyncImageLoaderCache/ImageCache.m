//
//  ImageCache.m
//  FB_Radar
//
//  Created by Sonny Black on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageCache.h"
#import "ImageCacheObject.h"

@implementation ImageCache

@synthesize totalSize;

-(id)initWithMaxSize:(NSUInteger) max  {
    if (self = [super init]) {
        totalSize = 0;
        maxSize = max;
        myDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) clearCache{
    [myDictionary removeAllObjects];
}

-(void)dealloc {
    [myDictionary release];
    [super dealloc];
}

-(void)insertImage:(UIImage*)image withSize:(NSUInteger)sz forKey:(NSString*)key{
    ImageCacheObject *object = [[ImageCacheObject alloc] initWithSize:sz Image:image];
    while (totalSize + sz > maxSize) {
        NSDate *oldestTime = nil;
        NSString *oldestKey = nil;
        for (NSString *key in [myDictionary allKeys]) {
            ImageCacheObject *obj = [myDictionary objectForKey:key];
            if (oldestTime == nil || [obj.timeStamp compare:oldestTime] == NSOrderedAscending) {
                oldestTime = obj.timeStamp;
                oldestKey = key;
            }
        }
        if (oldestKey == nil) 
            break; // shoudn't happen
        ImageCacheObject *obj = [myDictionary objectForKey:oldestKey];
        totalSize -= obj.size;
        [myDictionary removeObjectForKey:oldestKey];
    }
    [myDictionary setObject:object forKey:key];
    [object release];
}

-(UIImage*)imageForKey:(NSString*)key {
    ImageCacheObject *object = [myDictionary objectForKey:key];
    if (object == nil)
        return nil;
    [object resetTimeStamp];
    return object.image;
}

@end
