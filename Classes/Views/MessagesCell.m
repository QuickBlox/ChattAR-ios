//
//  MessagesCell.m
//  ChattAR
//
//  Created by Igor Alefirenko on 13/01/2014.
//  Copyright (c) 2014 Stefano Antonelli. All rights reserved.
//

#import "MessagesCell.h"

@implementation MessagesCell

- (void) layoutSubviews {
    [super layoutSubviews];
    [self setBackgroundColor:[UIColor colorWithWhite:0.35 alpha:1.0]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // set selection style: blue
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:0 green:0.4 blue:0.6 alpha:1.0];
    bgColorView.layer.masksToBounds = YES;
    self.selectedBackgroundView = bgColorView;
}

@end
