//
//  ButtonWithUnderlining.m
//  Nova Head & Neck
//
//  Created by Igor Khomenko on 14.04.11.
//  Copyright 2011 injoit. All rights reserved.
//

#import "ButtonWithUnderlining.h"

@implementation ButtonWithUnderlining

@synthesize linkedUrl;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) {
        return nil;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorRef color = [[self titleColorForState:self.state] CGColor];
    
    const CGFloat *componets = CGColorGetComponents(color);
    const int number = CGColorGetNumberOfComponents(color);

    if(number == 4){
        CGContextSetRGBStrokeColor(context,  componets[0], componets[1], componets[2], componets[3]);
    }else if(number == 2){// white/black color
        CGContextSetRGBStrokeColor(context,  componets[0], componets[0], componets[0], componets[1]);
    }
    
    // Draw them with a 1.0 stroke width.
    CGContextSetLineWidth(context, 0.5);
    
    float fontSize = [self titleLabel].font.pointSize;
    
    // Draw a single line from left to right
	CGContextMoveToPoint(context, 1, rect.size.height/2+fontSize/2);
	CGContextAddLineToPoint(context, rect.size.width-1, rect.size.height/2+fontSize/2);
    CGContextStrokePath(context);
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(linkedUrl){
        [[UIApplication sharedApplication] openURL:linkedUrl];
    }else {
		[super touchesEnded:touches withEvent:event];
	}
}

- (void)dealloc {
    [linkedUrl release];
    [super dealloc];
}

@end