//
//  SettingsViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 28/08/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
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
    [Flurry logEvent:kFlurryEventAboutScreenWasOpened];
}

- (IBAction)gotoURL:(id)sender
{
    NSString* urlString = @"https://github.com/QuickBlox/ChattAR-ios";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}
@end
