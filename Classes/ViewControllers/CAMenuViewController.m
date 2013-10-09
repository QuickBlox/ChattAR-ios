//
//  CAMenuViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 04/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "CAMenuViewController.h"
#import "SplashViewController.h"
#import "SASlideMenuRootViewController.h"
#import "FBService.h"
#import <QuartzCore/QuartzCore.h>
#import "MenuCell.h"
#import "ProfileCell.h"
#import "FBStorage.h"


@implementation CAMenuViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}


#pragma mark - 
#pragma mark ViewController Lifecycle

- (void)viewDidUnload {
    [self setFirstNameField:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
    NSString *firstLastName = [NSString stringWithFormat:@"%@ %@", kGetFBFirstName,kGetFBLastName];
    [self.firstNameField setText:firstLastName];
    [super viewWillAppear:NO];
    UIImage *img = [UIImage imageNamed:@"qb_mnu_grey.png"];
    UIImageView *logoImage = [[UIImageView alloc] initWithImage:img];
    logoImage.frame = CGRectMake(40, _menuTable.frame.size.height - (img.size.height + 30), img.size.width, img.size.height);
    [self.menuTable addSubview:logoImage];
}

#pragma mark -
#pragma mark SASlideMenuDataSource

// This is the indexPath selected at start-up
- (NSIndexPath*) selectedIndexPath{
    return [NSIndexPath indexPathForRow:2 inSection:0];
}

- (NSString*) segueIdForIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 2) {
        return kChatSegueIdentifier;
    }else if (indexPath.row == 3){
        return kMapSegueIdentifier;
    }else if (indexPath.row == 4){
        return kARSegueIdentifier;
    } else if (indexPath.row == 5) {
        return kAboutSegueIdentifier;
    } else return @"";
}

- (Boolean) allowContentViewControllerCachingForIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (Boolean) disablePanGestureForIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row ==0) {
        return YES;
    }
    return NO;
}

// This is used to configure the menu button. The beahviour of the button should not be modified
- (void) configureMenuButton:(UIButton *)menuButton{
    menuButton.frame = CGRectMake(0, 0, 40, 29);
    [menuButton setImage:[UIImage imageNamed:@"mnubtn.png"] forState:UIControlStateNormal];
    [menuButton setBackgroundColor:[UIColor clearColor]];
}

- (void) configureSlideLayer:(CALayer *)layer{
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.3;
    layer.shadowOffset = CGSizeMake(-15, 0);
    layer.shadowRadius = 10;
    layer.masksToBounds = NO;
    layer.shadowPath =[UIBezierPath bezierPathWithRect:layer.bounds].CGPath;
}

- (CGFloat) leftMenuVisibleWidth{
    return 250;
}
- (void)prepareForSwitchToContentViewController:(UINavigationController *)content{
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
    [[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject] endEditing:YES];
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


#pragma mark -
#pragma mark Log Out ChattAR

- (IBAction)logOutChat:(id)sender {    
    
    // logout XMPP fb chat
    [[FBService shared] logOutChat];

    //log out from facebook
    if ([FBSession activeSession].state == FBSessionStateOpen) {
        [[FBSession activeSession] closeAndClearTokenInformation];
    }

    //log out from QBChat
    [[QBChat instance] logout];

    //Destroy QBSession
    [QBAuth destroySessionWithDelegate:nil];
    //clear  FBAccessToken and FBUser from DataManager
    [[FBStorage shared] clearFBAccess];
    [[FBStorage shared] clearFBUser];
}

@end
