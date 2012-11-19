//
//  SettingsController.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 3/10/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface SettingsController : UIViewController <UIAlertViewDelegate>{
    BOOL isInitialized;
}

@property (nonatomic, assign) IBOutlet AsyncImageView *userProfilePicture;
@property (nonatomic, assign) IBOutlet UILabel *userName;
@property (nonatomic, assign) IBOutlet UILabel *userStatus;

@property (nonatomic, assign) IBOutlet UISwitch* vibrateSwitch;
@property (nonatomic, assign) IBOutlet UISwitch* soundSwitch;
@property (retain, nonatomic) IBOutlet UIButton *clearcacheButton;

@property (retain, nonatomic) IBOutlet UILabel *developedLabel;
@property (retain, nonatomic) IBOutlet UILabel *arChatLabel;
@property (retain, nonatomic) IBOutlet UIButton *linkButton;
@property (retain, nonatomic) IBOutlet UIButton *linkButtonQB;
@property (retain, nonatomic) IBOutlet UIImageView *shadowImageView;

-(IBAction)switchValueDidChange:(UISwitch *)switchView;
-(IBAction)linksAction:(id)sender;
-(void)logoutButtonDidPress;
- (IBAction)clearCache:(id)sender;

@end
