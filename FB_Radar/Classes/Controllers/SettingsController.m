//
//  SettingsController.m
//  FB Radar
//
//  Created by md314 on 3/10/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "SettingsController.h"
#import "DataManager.h"
#import "ButtonWithUnderlining.h"
#import "AppDelegate.h"
#import "WebViewController.h"

@interface SettingsController ()

@end

@implementation SettingsController

@synthesize userProfilePicture = _userProfilePicture;
@synthesize userName = _userName;
@synthesize vibrateSwitch = _vibrateSwitch;
@synthesize soundSwitch = _soundSwitch;
@synthesize clearcacheButton = _clearcacheButton;
@synthesize userStatus = _userStatus;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Settings", @"Settings");
        self.tabBarItem.image = [UIImage imageNamed:@"DockSettings.png"];
        
        isInitialized = NO;
    }
    return self;
}

- (void)dealloc{
    [_clearcacheButton release];
	[super dealloc];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // add logout button
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Logout", nil) 
                                                                     style:UIBarButtonItemStylePlain 
                                                                    target:self 
                                                                    action:@selector(logoutButtonDidPress)]; 
    self.navigationItem.rightBarButtonItem = logoutButton;
    [logoutButton release];


    // set switches state
    _soundSwitch.on = [NotificationManager isSoundEnabled];
    _vibrateSwitch.on = [NotificationManager isVibrationEnabled];

}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(!isInitialized){
        isInitialized = YES;
        
        // show photo & user name
        [_userProfilePicture loadImageFromURL:[NSURL URLWithString:[[DataManager shared].currentFBUser objectForKey:kPicture]]];
        [_userName setText:[[DataManager shared].currentFBUser objectForKey:kName]];
        
        NSDictionary *location = [[DataManager shared].currentFBUser objectForKey:kLocation];
        if(!location){
            location = [[DataManager shared].currentFBUser objectForKey:kHometown];
        }
        
        [_userStatus setText:[location objectForKey:kName]];
    }
}

- (void)viewDidUnload{
    [self setUserProfilePicture:nil];
    [self setUserName:nil];
    [self setVibrateSwitch:nil];
    [self setSoundSwitch:nil];
    [self setUserStatus:nil];

    [self setClearcacheButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// Links actions
-(IBAction)linksAction:(id)sender{
    NSString *url;
	if (((ButtonWithUnderlining*)sender).tag == 0){
		url = @"http://injoit.com/";
	}else {
		url = @"http://quickblox.com/";
	}
    
    WebViewController *webViewControleler = [[WebViewController alloc] init];
    webViewControleler.urlAdress = url;
    webViewControleler.webView.scalesPageToFit = YES;
	[self.navigationController pushViewController:webViewControleler animated:YES];
    [webViewControleler autorelease];
}

// logout
-(void)logoutButtonDidPress{
    
    isInitialized = NO;
    
    // notify
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLogout object:nil];
    
    // logout
    [[FBService shared].facebook logout];
    [[FBService shared] logOutChat];
    
    
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) showSplashWithAnimation:YES];
    
    NSLog(@"LogOut");
}

- (IBAction)clearCache:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you really want to clear the cache?" delegate:self cancelButtonTitle:@"Cansel" otherButtonTitles:@"Yes", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Yes"])
    {
        [[DataManager shared] clearCache];
    }
}

// Sound/Vibro
-(void)switchValueDidChange:(UISwitch *)switchView{
    switch (switchView.tag) {

        // Sound - enable/disable 
        case 1:
            [NotificationManager soundEnable:switchView.on];
            break;
            
        // Vibration - enable/disable 
        case 2:
            [NotificationManager vibrationEnable:switchView.on];
            break;
            
        // PopUp - enable/disable 
        case 3:
            [NotificationManager popUpEnable:switchView.on];
            break;
            
        default:
            break;
    }
}

@end
