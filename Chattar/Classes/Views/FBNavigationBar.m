//
//  FBNavigationBar.m
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 11.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "FBNavigationBar.h"

@implementation FBNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect 
{
	UIImage *image = [UIImage imageNamed: @"navBar.png"];
	[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end
