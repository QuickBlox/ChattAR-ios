//
//  CustomSwitch.m


#import "CustomSwitch.h"

@implementation CustomSwitch

@synthesize on;
@synthesize tintColor, clippingView, leftLabel, rightLabel, centerLabel;

+ (CustomSwitch *) switchWithLeftText:(NSString *)leftText andRight:(NSString *)rightText {
    
	CustomSwitch *switchView = [[CustomSwitch alloc] initWithFrame:CGRectZero];
	
	return [switchView autorelease];
}

- (id) initWithFrame: (CGRect)rect{
	if ((self=[super initWithFrame:CGRectMake(rect.origin.x,rect.origin.y,70,0)])){
		[self awakeFromNib];
	}
	return self;
}

- (void)setValue:(float)value{
    [super setValue:value];
    if(value == 1){
        on = YES;
    }else if (value == 0){
        on = NO;
    }
}

- (void) awakeFromNib {
	[super awakeFromNib];
	
	self.backgroundColor = [UIColor clearColor];
    
	[self setThumbImage:[UIImage imageNamed:@"Circle.png"] forState:UIControlStateNormal];
	[self setMinimumTrackImage:[UIImage imageNamed:@"Switcher_world.png"] forState:UIControlStateNormal];
	[self setMaximumTrackImage:[UIImage imageNamed:@"Switcher_fb.png"] forState:UIControlStateNormal];
	
	self.minimumValue = 0;
	self.maximumValue = 1;
	self.continuous = NO;
}

-(void)layoutSubviews{
	[super layoutSubviews];
	
	// move the labels to the front
    [self bringSubviewToFront:clippingView];
}

- (void)scaleSwitch:(float)newSize {
	self.transform = CGAffineTransformMakeScale(newSize,newSize);
}

- (UIImage *)image:(UIImage*)image tintedWithColor:(UIColor *)tint {	
    
    if (tint != nil) {
		UIGraphicsBeginImageContext(image.size);
        
		//draw mask so the alpha is respected
		CGContextRef currentContext = UIGraphicsGetCurrentContext();
		CGImageRef maskImage = [image CGImage];
		CGContextClipToMask(currentContext, CGRectMake(0, 0, image.size.width, image.size.height), maskImage);
		CGContextDrawImage(currentContext, CGRectMake(0,0, image.size.width, image.size.height), image.CGImage);
		
		[image drawAtPoint:CGPointMake(0,0)];
		[tint setFill];
		UIRectFillUsingBlendMode(CGRectMake(0,0,image.size.width,image.size.height),kCGBlendModeColor);
		UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
        
        return newImage;
    }else {
        return image;
    }
}


- (void) setTintColor:(UIColor*)color {
	if (color != tintColor){
		[tintColor release];
		tintColor = [color retain];
		
		[self setMinimumTrackImage:[self image:[UIImage imageNamed:@"switchBlueBg.png"] tintedWithColor:tintColor] forState:UIControlStateNormal];
	}
}

// ON\OFF
- (void) setOn:(BOOL)turnOn {
    [self setOn:turnOn animated:NO];
}

- (void) setOn:(BOOL)turnOn animated:(BOOL)animated {
	on = turnOn;
	
	if (animated) {
		[UIView	 beginAnimations:@"CustomSwitch" context:nil];
		[UIView setAnimationDuration:0.2];
	}
	
	if (on) {
		self.value = 1.0;
	} else {
		self.value = 0.0;
	}
	
	if (animated) {
		[UIView	commitAnimations];	
	}
    
    [self performSelector:@selector(valueDidChange) withObject:nil afterDelay:0.05];
}

- (void)valueDidChange{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	[super endTrackingWithTouch:touch withEvent:event];
    
	m_touchedSelf = YES;
	
	[self setOn:on animated:YES];
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	[super touchesBegan:touches withEvent:event];
    
	m_touchedSelf = NO;
	on = !on;
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	[super touchesEnded:touches withEvent:event];
	
	if (!m_touchedSelf){
		[self setOn:on animated:YES];
	}
}

- (void) dealloc {
	[tintColor release];
    
	[super dealloc];
}

@end
