//
//  GILockedInterface.m
//  Gistr-iOS
//
//  Created by Ruslan on 8/7/13.
//  Copyright (c) 2013 Injoit. All rights reserved.
//

#import "GILockedInterface.h"

static UIView *backgroundView = nil;

@interface GILockedInterface () {}

@end

@implementation GILockedInterface {}

#pragma mark -
#pragma mark public

+ (void)lockInterface {
    if (!backgroundView) {
        backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        backgroundView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        indicator.center = backgroundView.center;
        [backgroundView addSubview:indicator];
        [indicator startAnimating];
    }
    [[[[UIApplication sharedApplication] windows] lastObject] addSubview:backgroundView];
}

+ (void)unlockInterface {
    if (backgroundView) {
        [backgroundView removeFromSuperview];
        backgroundView = nil;
    }
}

@end
