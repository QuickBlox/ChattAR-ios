//
//  TestManager.m
//  Chattar
//
//  Created by Igor Khomenko on 4/2/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "TestManager.h"

static TestManager *instance = nil;

@implementation TestManager

@synthesize testLocations;

+ (TestManager *)shared {
	@synchronized (self) {
		if (instance == nil){ 
            instance = [[self alloc] init];
        }
	}
	
	return instance;
}

- (id)init {
    self = [super init];
    
    if(self) {
        // point 1
        NSString *userID1 = @"100000349082603"; // Julia Sydorenko
        NSArray *coord1 = [NSArray arrayWithObjects:[NSNumber numberWithDouble:50.0], [NSNumber numberWithDouble:27.0], nil];// lat, lon

        
        self.testLocations = [NSDictionary dictionaryWithObjectsAndKeys:coord1, userID1, nil];
    }
    
    return self;
}

- (void)dealloc
{
    [testLocations release];
    [super dealloc];
}

@end
