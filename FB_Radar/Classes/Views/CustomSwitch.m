//
//  CustomSwitch.m


#import "CustomSwitch.h"

@implementation CustomSwitch

@synthesize on;

+ (CustomSwitch *) customSwitch {
	CustomSwitch *switchView = [[CustomSwitch alloc] initWithFrame:CGRectZero];
	return [switchView autorelease];
}

- (id) initWithFrame: (CGRect)rect{
	if (self = [super initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, 68, rect.size.height)]){
		[self awakeFromNib];
	}
	return self;
}

- (void)setValue:(float)value{
    [super setValue:value];
    if(value >= worldValue){
        on = YES;
    }else if (value <= friendsValue){
        on = NO;
    }
    
    NSLog(@"On=%d, value=%f", on, value);
}

- (void) awakeFromNib {
	[super awakeFromNib];
	
	self.backgroundColor = [UIColor clearColor];
    
	[self setThumbImage:[UIImage imageNamed:@"circle.png"] forState:UIControlStateNormal];

    if(IS_IOS_6){
        [self setMinimumTrackImage:[[UIImage imageNamed:@"allSwitch.png"] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"0")] forState:UIControlStateNormal];
        [self setMaximumTrackImage:[[UIImage imageNamed:@"friendsSwitch.png"] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"0")] forState:UIControlStateNormal];
    }else {
        [self setMinimumTrackImage:[UIImage imageNamed:@"allSwitch.png"] forState:UIControlStateNormal];
        [self setMaximumTrackImage:[UIImage imageNamed:@"friendsSwitch.png"] forState:UIControlStateNormal];        
    }
	
	self.minimumValue = 0;
	self.maximumValue = 1;
	self.continuous = NO;
}
 
- (void)scaleSwitch:(float)newSize {
	self.transform = CGAffineTransformMakeScale(newSize,newSize);
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
		self.value = worldValue;
	} else {
		self.value = friendsValue;
	}
	
	if (animated) {
		[UIView	commitAnimations];	
	}
    
    [self performSelector:@selector(valueDidChange) withObject:nil afterDelay:0.05];
}

- (void)valueDidChange{
    valueChangedSelf = YES;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents{
    if(valueChangedSelf){
        [super sendActionsForControlEvents:controlEvents];
        valueChangedSelf = NO;
    }
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
	[super dealloc];
}

@end
