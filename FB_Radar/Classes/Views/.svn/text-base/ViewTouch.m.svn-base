//
//  ViewTouch.m
//  FB_Radar
//
//  Created by Sonny Black on 11.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewTouch.h"

@implementation ViewTouch

-(id) initWithFrame:(CGRect)frame selector:(SEL)sel target:(id)tar
{
	self = [super initWithFrame:frame];
	
	if(self){
		selector = sel;
		target = tar;
		return self;
	}
	return nil;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[target performSelector:selector];
}

- (void) dealloc 
{
    [super dealloc];
}


@end
