//
//  MenuViewController.h
//  ChattAR
//
//  Created by Igor Alefirenko on 04/09/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASlideMenuViewController.h"
#import "SASlideMenuDataSource.h"
#import "MenuCell.h"

@interface MenuViewController : SASlideMenuViewController <SASlideMenuDataSource,SASlideMenuDelegate>

@property (strong, nonatomic) IBOutlet UILabel *firstNameField;
@property (strong, nonatomic) IBOutlet UITableView *menuTable;

- (IBAction)logOutChat:(id)sender;

@end
