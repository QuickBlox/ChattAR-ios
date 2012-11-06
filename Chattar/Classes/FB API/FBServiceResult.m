//
//  FBServiceResult.m
//  FB_Radar
//
//  Created by Sonny Black on 07.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FBServiceResult.h"

@implementation FBServiceResult

@synthesize body, queryType, context;

- (void)dealloc
{
    [body release];
    [super dealloc];
}

@end
