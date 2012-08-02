//
//  CustomButtonWithQuote.m
//  FB_Radar
//
//  Created by Alexey on 11.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomButtonWithQuote.h"

@implementation CustomButtonWithQuote
@synthesize quote;

- (id)init
{
	self = [super init];
	if (self)
	{
		quote = [[NSMutableDictionary alloc] init];
	}
	return self;
}



-(void)dealloc
{
	[quote release];
	
	[super dealloc];
}

@end
