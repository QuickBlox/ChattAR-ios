//
//  AppDelegate.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 03.05.12.
//  Copyright (c) 2012 QuickBlox. All rights ячс reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>{
}
@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) UITabBarController *tabBarController;

- (void)showSplashWithAnimation:(BOOL) animated;
- (void)showSplashWithAnimation:(BOOL) animated showLoginButton:(BOOL)isShow;

@end
