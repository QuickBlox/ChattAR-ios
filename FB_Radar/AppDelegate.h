//
//  AppDelegate.h
//  FB_Radar
//
//  Created by Sonny Black on 03.05.12.
//  Copyright (c) 2012 Injoit. All rights ячс reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>{
}
@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) UITabBarController *tabBarController;

- (void)showSplashWithAnimation:(BOOL) animated;

@end
