//
//  SettingsController.h
//  Fbmsg
//
//  Created by md314 on 3/10/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface SettingsController : UIViewController{
    BOOL isInitialized;
}

@property (nonatomic, assign) IBOutlet AsyncImageView *userProfilePicture;
@property (nonatomic, assign) IBOutlet UILabel *userName;
@property (nonatomic, assign) IBOutlet UILabel *userStatus;

@property (nonatomic, assign) IBOutlet UISwitch* vibrateSwitch;
@property (nonatomic, assign) IBOutlet UISwitch* soundSwitch;
@property (nonatomic, assign) IBOutlet UISwitch* popUpSwitch;

-(IBAction)switchValueDidChange:(UISwitch *)switchView;
-(IBAction)linksAction:(id)sender;
-(void)logoutButtonDidPress;

@end
