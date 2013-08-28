//
//  ProfileCell.m
//  SASlideMenu
//
//  Created by Igor Alefirenko on 23/08/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "ProfileCell.h"

@implementation ProfileCell

-(void) layoutSubviews{
    [super layoutSubviews];
    [self setBackgroundColor:[UIColor colorWithWhite:0.13 alpha:1.0]];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}


@end
