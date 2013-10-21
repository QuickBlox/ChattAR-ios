//
//  CAMenuViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 04/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//
#import "SASlideMenuViewController.h"
#import "SASlideMenuRootViewController.h"
#import "CAMenuViewController.h"
#import "SplashViewController.h"
#import "SASlideMenuRootViewController.h"
#import "FBService.h"
#import <QuartzCore/QuartzCore.h>
#import "MenuCell.h"
#import "ProfileCell.h"
#import "FBStorage.h"
#import "Utilites.h"


@implementation CAMenuViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}


#pragma mark - 
#pragma mark ViewController Lifecycle

- (void)viewDidUnload{
    [self setFirstNameField:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self configureQButton];
    // still supprots
        double delayInSeconds = 4;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (![Utilites deviceSupportsAR]) {
                NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:4 inSection:0]];
                _isArNotAvailable = YES;
                [self.menuTable deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            }
            [self.menuTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        });
}

-(void)configureQButton{
    UIImage *img = [UIImage imageNamed:@"qb_mnu_grey.png"];
    UIButton *qbButton = [[UIButton alloc] init];
    qbButton.backgroundColor = [UIColor colorWithPatternImage:img];
    qbButton.frame = CGRectMake(40, _menuTable.frame.size.height - (img.size.height + 30), img.size.width, img.size.height);
    [qbButton addTarget:self action:@selector(gotoQBSite) forControlEvents:UIControlEventTouchUpInside];
    [self.menuTable addSubview:qbButton];
}

- (void)viewWillAppear:(BOOL)animated{
    NSString *firstLastName = [NSString stringWithFormat:@"%@ %@", kGetFBFirstName,kGetFBLastName];
    [self.firstNameField setText:firstLastName];
    [super viewWillAppear:NO];
    //[self.menuTable reloadData];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows;
    if (_isArNotAvailable) {
        rows = 5;
    }else {
        rows = 6;
    }
    return rows;
}


#pragma mark -
#pragma mark SASlideMenuDataSource

// This is the indexPath selected at start-up
- (NSIndexPath*) selectedIndexPath{
    return [NSIndexPath indexPathForRow:2 inSection:0];
}

- (NSString*) segueIdForIndexPath:(NSIndexPath *)indexPath{
    NSString *segue = [NSString string];
    switch ([indexPath row]) {
        case 2:
            segue = kChatSegueIdentifier;
            break;
        case 3:
            segue = kMapSegueIdentifier;
            break;
        case 4:
            if (!_isArNotAvailable) {
                segue = kARSegueIdentifier;
            } else {
            segue = kAboutSegueIdentifier;
            }
            break;
        case 5:
            segue = kAboutSegueIdentifier;
            break;
            
        default:
            break;
    }
    return segue;
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

- (void)gotoQBSite{
    NSString* urlString = @"http://quickblox.com";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
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


//#pragma mark -
//#pragma mark NSNotificationCenter
//
//-(void)setBlueSelectionOfRow{
//    [[NSNotificationCenter defaultCenter]  removeObserver:self];
//    [self.menuTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
//}

@end
