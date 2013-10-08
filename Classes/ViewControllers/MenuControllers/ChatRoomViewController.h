//
//  ChatRoomViewController.h
//  ChattAR
//
//  Created by Igor Alefirenko on 11/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utilites.h"
#import "SASlideMenuDelegate.h"

@interface ChatRoomViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, QBChatDelegate, QBActionStatusDelegate, CLLocationManagerDelegate, UIActionSheetDelegate, SASlideMenuDelegate>

@property (strong, nonatomic) IBOutlet UITableView *chatRoomTable;

typedef struct {
    CGFloat latitude;
    CGFloat longitude;
} LocationCoordinates;

- (IBAction)share:(id)sender;

@end
