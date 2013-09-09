//
//  CAMenuViewController.h
//  ChattAR
//
//  Created by Igor Alefirenko on 04/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASlideMenuViewController.h"
#import "SASlideMenuDataSource.h"

@interface CAMenuViewController :SASlideMenuViewController <SASlideMenuDataSource,SASlideMenuDelegate, UIAlertViewDelegate, QBActionStatusDelegate, QBChatDelegate>
@property (strong, nonatomic) IBOutlet UILabel *firstNameField;

- (IBAction)logOutChat:(id)sender;

@end
