//
//  MenuViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 04/09/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "SASlideMenuViewController.h"
#import "SASlideMenuRootViewController.h"
#import "MenuViewController.h"
#import "SplashViewController.h"
#import "SASlideMenuRootViewController.h"
#import "FBService.h"
#import <QuartzCore/QuartzCore.h>
#import "MenuCell.h"
#import "UserProfileCell.h"
#import "ChatRoomStorage.h"
#import "FBStorage.h"
#import "Utilites.h"
#import "QBService.h"
#import "QBStorage.h"

@interface MenuViewController ()

@property (strong, nonatomic) IBOutlet UILabel *unreadMsgRank;
@property (strong, nonatomic) IBOutlet UIImageView *redBubleForRank;

@end

@implementation MenuViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}


#pragma mark - 
#pragma mark ViewController Lifecycle

- (void)viewDidUnload
{
    [self setFirstNameField:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureQButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackAllUnreadMessagesCount) name:CADialogsHideUnreadMessagesLabelNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackAllUnreadMessagesCount) name:CAChatDidReceiveOrSendMessageNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    NSString *firstLastName = [[FBStorage shared].me objectForKey:kName];
    [self.firstNameField setText:firstLastName];
    if (![Utilites shared].isArNotAvailable) {
        [self checkForARModuleAvailable];
    }
    [self.menuTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}


#pragma mark - 
#pragma mark Options

- (void)checkForARModuleAvailable
{
    if (![Utilites deviceSupportsAR]) {
        NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:4 inSection:0]];
        [Utilites shared].isArNotAvailable = YES;
        [self.menuTable deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
}


#pragma mark -
#pragma mark QuickBlox Button

- (void)configureQButton
{
    UIImage *img = [UIImage imageNamed:@"qb_mnu_grey.png"];
    UIButton *qbButton = [[UIButton alloc] init];
    qbButton.backgroundColor = [UIColor colorWithPatternImage:img];
    if (IS_HEIGHT_GTE_568) {
        qbButton.frame = CGRectMake(40, _menuTable.frame.size.height - (img.size.height+30), img.size.width, img.size.height);
    } else {
        if (!IS_IOS_6) {
        qbButton.frame = CGRectMake(40, _menuTable.frame.size.height - (img.size.height+5), img.size.width, img.size.height);
        }
    }
    [qbButton addTarget:self action:@selector(gotoQBSite) forControlEvents:UIControlEventTouchUpInside];
    [self.menuTable addSubview:qbButton];
}

// action
- (void)gotoQBSite {
    [Flurry logEvent:kFlurryEventQuickbloxButtonWasPressed];
    NSString* urlString = @"http://quickblox.com";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;
    if ([Utilites shared].isArNotAvailable) {
        rows = 6;
    }else {
        rows = 7;
    }
    return rows;
}


#pragma mark -
#pragma mark SASlideMenuDataSource

// This is the indexPath selected at start-up
- (NSIndexPath*)selectedIndexPath {
    [[ControllerStateService shared] setControllerIndex:2];
    return [NSIndexPath indexPathForRow:2 inSection:0];
}

- (NSString*)segueIdForIndexPath:(NSIndexPath *)indexPath {
    [QBService defaultService].userIsJoinedChatRoom = NO;
    NSString *segue = nil;
    switch ([indexPath row]) {
        case 2:
            [[ControllerStateService shared] setControllerIndex:2];
            segue = kChatSegueIdentifier;
            break;
        case 3:
            [[ControllerStateService shared] setControllerIndex:3];
            segue = kMapSegueIdentifier;
            break;
        case 4:
            [[ControllerStateService shared] setControllerIndex:4];
            if (![Utilites shared].isArNotAvailable) {
                segue = kARSegueIdentifier;
            } else {
            segue = kDialogsSegueIdentifier;
            }
            break;
        case 5:
            [[ControllerStateService shared] setControllerIndex:5];
            if (![Utilites shared].isArNotAvailable) {
                segue = kDialogsSegueIdentifier;
            } else {
                segue = kAboutSegueIdentifier;
            }
            break;
        case 6:
            [[ControllerStateService shared] setControllerIndex:6];
            segue = kAboutSegueIdentifier;
            break;
            
        default:
            break;
    }
    return segue;
}

- (Boolean)allowContentViewControllerCachingForIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (Boolean)disablePanGestureForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row ==0) {
        return YES;
    }
    return NO;
}

// This is used to configure the menu button. The beahviour of the button should not be modified
- (void)configureMenuButton:(UIButton *)menuButton {
    menuButton.frame = CGRectMake(0, 0, 40, 29);
    [menuButton setImage:[UIImage imageNamed:@"mnubtn.png"] forState:UIControlStateNormal];
    [menuButton setBackgroundColor:[UIColor clearColor]];
}

- (void)configureSlideLayer:(CALayer *)layer {
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.3;
    layer.shadowOffset = CGSizeMake(-15, 0);
    layer.shadowRadius = 10;
    layer.masksToBounds = NO;
    layer.shadowPath =[UIBezierPath bezierPathWithRect:layer.bounds].CGPath;
}

- (CGFloat)leftMenuVisibleWidth {
    return 250;
}
- (void)prepareForSwitchToContentViewController:(UINavigationController *)content {
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
    [[[UIApplication sharedApplication].windows firstObject] endEditing:YES];
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
    if ([FBSession activeSession].state == FBSessionStateOpen || [FBSession activeSession].state == FBSessionStateOpenTokenExtended) {
        [[FBSession activeSession] closeAndClearTokenInformation];
    }

    //log out from QBChat
    [[QBChat instance] logout];
    [QBService defaultService].presenceTimer = nil;
    [QBStorage shared].me = nil;

    //Destroy QBSession
    [QBAuth destroySessionWithDelegate:nil];
    
    [[FBStorage shared] setAccessToken:nil];
    [[FBStorage shared] setMe:nil];
    [Flurry logEvent:kFlurryEventUserWasLoggedOut];
}


#pragma mark -
#pragma mark Unread Messages

- (void)trackAllUnreadMessagesCount
{
    if ([ControllerStateService shared].isInDialog) {
        return;
    }
    int unreadMsgCount = [[ChatRoomStorage shared] trackAllUnreadMessages];
    
    if (unreadMsgCount == 0) {
        self.redBubleForRank.hidden = YES;
        self.unreadMsgRank.hidden = YES;
    } else {
        self.unreadMsgRank.text = [NSString stringWithFormat:@"%d", unreadMsgCount];
        self.redBubleForRank.hidden = NO;
        self.unreadMsgRank.hidden = NO;
    }
}

@end
