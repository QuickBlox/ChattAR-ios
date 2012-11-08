//
//  FBServiceResult.m
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 07.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
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
