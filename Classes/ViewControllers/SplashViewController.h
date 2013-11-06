//
//  SplashViewController.h
//  SASlideMenu
//
//  Created by Igor Alefirenko on 22/08/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashViewController : UIViewController <FBLoginViewDelegate, QBActionStatusDelegate, QBChatDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatior;

- (IBAction)logIn:(id)sender;

@end
