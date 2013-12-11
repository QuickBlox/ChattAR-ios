//
//  MapAnnotationView.m
//  ChattAR
//
//  Created by Igor Alefirenko on 07/10/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "MapAnnotationView.h"

@implementation MapAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.avatar = [[AsyncImageView alloc] initWithFrame:CGRectMake(9, 9, 44, 44)];
        [self addSubview:_avatar];
    }
    return self;
}

- (void)handleAnnotationView {
    self.canShowCallout = YES;
    
    UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [accessoryButton setAdjustsImageWhenHighlighted:NO];
    CGFloat value = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (!IS_IOS_6) {
        [accessoryButton setImage:[UIImage imageNamed:@"pincallout.png"] forState:UIControlStateNormal];
    }
    accessoryButton.tag = kAnnotationButtonTag;
    self.rightCalloutAccessoryView = accessoryButton;
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pinicon.png"]];
    imgView.frame = CGRectMake(0, 0, 12, 18);
    self.leftCalloutAccessoryView = imgView;
    
    self.centerOffset = CGPointZero;
    self.image = [UIImage imageNamed:@"03_pin.png"];
}

@end
