//
//  VideoCallViewController.h
//  Chattar
//
//  Created by Andrey Kozlov on 07/01/2014.
//  Copyright (c) 2014 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoCallViewController : UIViewController

@property (nonatomic, weak) NSString *controllerTitle;
@property (nonatomic, strong) NSMutableDictionary *destinationUser;

@end
