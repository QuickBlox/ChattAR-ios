//
//  SplashViewSegue.m
//  ChattAR
//
//  Created by Igor Alefirenko on 27/08/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "SplashViewSegue.h"

@implementation SplashViewSegue

-(void)perform{
    [[self sourceViewController] presentModalViewController:[self destinationViewController] animated:NO];
}

@end
