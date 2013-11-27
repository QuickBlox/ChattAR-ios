//
//  SettingsViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 28/08/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "SettingsViewController.h"
#import "Utilites.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UILabel *bottomLabel;
@property (strong, nonatomic) IBOutlet UIButton *bottomButton;

- (IBAction)gotoURL:(id)sender;

@end

@implementation SettingsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!IS_HEIGHT_GTE_568){
        _bottomButton.hidden = YES;
        _bottomLabel.hidden = YES;
    }
}

- (IBAction)gotoURL:(id)sender
{
    NSString* urlString = @"https://github.com/QuickBlox/ChattAR-ios";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}
@end
