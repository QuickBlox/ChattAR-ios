//
//  SplashViewSegue.m
//  SASlideMenu
//
//  Created by Igor Alefirenko on 27/08/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "SplashViewSegue.h"



@implementation SplashViewSegue

-(void)perform{
    [[self sourceViewController] presentModalViewController:[self destinationViewController] animated:NO];
}

@end
