//
//  SplashViewController.h
//  ChattAR
//
//  Created by Igor Alefirenko on 22/08/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatior;

- (IBAction)logIn:(id)sender;

@end
