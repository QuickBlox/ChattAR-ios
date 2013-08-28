//
//  SplashViewController.m
//  SASlideMenu
//
//  Created by Igor Alefirenko on 22/08/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "SplashViewController.h"
#define IS_HEIGHT_GTE_568 [[UIScreen mainScreen ] bounds].size.height >= 568.0f

@interface SplashViewController ()

@end

@implementation SplashViewController
@synthesize backgroundImage;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(IS_HEIGHT_GTE_568){
        [backgroundImage setImage:[UIImage imageNamed:@"Default-568h@2x.png"]];
    } else [backgroundImage setImage:[UIImage imageNamed:@"Default@2x.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)logIn:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setBackgroundImage:nil];
    [super viewDidUnload];
}
@end
