//
//  ControllerStateService.h
//  ChattAR
//
//  Created by Igor Alefirenko on 02/01/2014.
//  Copyright (c) 2014 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ControllerStateService : NSObject

// Dialog view controller activity. When user hides an app, staying in Dialog VC, flag sets to YES. By default - NO.
@property (nonatomic, assign) BOOL isInDialog;

// ChatRoom view controller activity. When user hides an app, staying in ChatRoom VC, flag sets to YES. By default - NO.
@property (nonatomic, assign) BOOL isInChatRoom;

// Index of controller, which was being active, when app hides
@property (nonatomic, assign) NSUInteger controllerIndex;

@property (nonatomic, strong) NSIndexPath *lastIndexPath;

+ (instancetype)shared;

@end
