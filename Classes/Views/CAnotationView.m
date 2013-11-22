//
//  CAnotationView.m
//  ChattAR
//
//  Created by Igor Alefirenko on 07/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "CAnotationView.h"

@implementation CAnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.avatar = [[UIImageView alloc] initWithFrame:CGRectMake(11, 13, 40, 40)];
        [self addSubview:_avatar];
    }
    return self;
}

- (void)handleAnnotationView {
    self.canShowCallout = YES;
    
    UIButton *accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [accessoryButton setAdjustsImageWhenHighlighted:NO];
    [accessoryButton setImage:[UIImage imageNamed:@"pincallout.png"] forState:UIControlStateNormal];
    accessoryButton.tag = kAnnotationButtonTag;
    self.rightCalloutAccessoryView = accessoryButton;
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pinicon.png"]];
    imgView.frame = CGRectMake(0, 0, 12, 18);
    self.leftCalloutAccessoryView = imgView;
    
    self.centerOffset = CGPointZero;
    self.image = [UIImage imageNamed:@"03_pin.png"];
    self.avatar.image = [UIImage imageNamed:@"room.jpg"];
}

@end
