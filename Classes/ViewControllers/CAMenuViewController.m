//
//  CAMenuViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 04/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "CAMenuViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "MenuCell.h"


@implementation CAMenuViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}


#pragma mark -
#pragma mark SASlideMenuDataSource

// This is the indexPath selected at start-up
-(NSIndexPath*) selectedIndexPath{
    return [NSIndexPath indexPathForRow:2 inSection:0];
}

-(NSString*) segueIdForIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 2) {
        return @"Chat";
    }else if (indexPath.row == 3){
        return @"Map";
    }else if (indexPath.row == 4){
        return @"AR";
    } else if (indexPath.row == 5) {
        return @"Messages";
    } else if (indexPath.row == 6) {
        return @"Settings";
    } else return @"";
}

-(Boolean) allowContentViewControllerCachingForIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(Boolean) disablePanGestureForIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row ==0) {
        return YES;
    }
    return NO;
}

// This is used to configure the menu button. The beahviour of the button should not be modified
-(void) configureMenuButton:(UIButton *)menuButton{
    menuButton.frame = CGRectMake(0, 0, 40, 29);
    [menuButton setImage:[UIImage imageNamed:@"mnubtn.png"] forState:UIControlStateNormal];
    [menuButton setBackgroundColor:[UIColor clearColor]];
}

-(void) configureSlideLayer:(CALayer *)layer{
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.3;
    layer.shadowOffset = CGSizeMake(-15, 0);
    layer.shadowRadius = 10;
    layer.masksToBounds = NO;
    layer.shadowPath =[UIBezierPath bezierPathWithRect:layer.bounds].CGPath;
}

-(CGFloat) leftMenuVisibleWidth{
    return 250;
}
-(void) prepareForSwitchToContentViewController:(UINavigationController *)content{
}


#pragma mark -
#pragma mark SASlideMenuDelegate

-(void) slideMenuWillSlideIn{
    NSLog(@"slideMenuWillSlideIn");
}
-(void) slideMenuDidSlideIn{
    NSLog(@"slideMenuDidSlideIn");
}
-(void) slideMenuWillSlideToSide{
    NSLog(@"slideMenuWillSlideToSide");
}
-(void) slideMenuDidSlideToSide{
    NSLog(@"slideMenuDidSlideToSide");
    
}
-(void) slideMenuWillSlideOut{
    NSLog(@"slideMenuWillSlideOut");
    
}
-(void) slideMenuDidSlideOut{
    NSLog(@"slideMenuDidSlideOut");
}

@end
