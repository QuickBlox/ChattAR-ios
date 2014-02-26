//
//  DetailDialogsViewController.h
//  ChattAR
//
//  Created by Igor Alefirenko on 29/10/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailDialogsViewController : UIViewController

@property (nonatomic, assign) BOOL isChatWithFacebookFriend;
@property (nonatomic, strong) NSMutableDictionary *conversation;
@property (nonatomic, strong) NSMutableDictionary *opponent;

@end
