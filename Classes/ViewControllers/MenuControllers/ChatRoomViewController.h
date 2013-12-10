//
//  ChatRoomViewController.h
//  ChattAR
//
//  Created by Igor Alefirenko on 11/09/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utilites.h"
#import "SASlideMenuDelegate.h"

@interface ChatRoomViewController : UIViewController 

@property (weak, nonatomic) NSString *controllerName;
@property (strong, nonatomic) IBOutlet UITableView *chatRoomTable;
@property (strong, nonatomic) QBCOCustomObject *currentChatRoom;

- (IBAction)share:(id)sender;

@end
