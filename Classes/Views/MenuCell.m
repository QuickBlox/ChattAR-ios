//
//  SASlideMenuCell.m
//  SASlideMenu
//
//  Created by Stefano Antonelli on 8/6/12.
//  Copyright (c) 2012 Stefano Antonelli. All rights reserved.
//

#import "MenuCell.h"
#import "Utilites.h"

@implementation MenuCell


-(void) layoutSubviews{
    [super layoutSubviews];
    [self setBackgroundColor:[UIColor colorWithWhite:0.35 alpha:1.0]];
}    

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // set selection style: blue
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:0 green:0.4 blue:0.6 alpha:1.0];
    bgColorView.layer.masksToBounds = YES;
    self.selectedBackgroundView = bgColorView;
}

@end
