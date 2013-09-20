//
//  ChatRoomViewController.h
//  ChattAR
//
//  Created by Igor Alefirenko on 11/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CachedUser.h"

@interface ChatRoomViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, QBChatDelegate, QBActionStatusDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITableView *chatRoomTable;
@property (nonatomic, strong) CachedUser *cashedUser;

typedef struct {
    CGFloat latitude;
    CGFloat longitude;
} LocationCoordinates;

@end
