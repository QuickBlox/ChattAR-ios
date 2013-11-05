//
//  DetailDialogsViewController.h
//  ChattAR
//
//  Created by Igor Alefirenko on 29/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBServiceResultDelegate.h"

@interface DetailDialogsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, QBActionStatusDelegate, QBChatDelegate>
@property (nonatomic, assign) NSNumber *friendPosition;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *inputTextView;
@property (strong, nonatomic) IBOutlet UITextField *inputMessageField;

@property (nonatomic, strong) NSMutableDictionary *conversation;
@property (nonatomic, strong) NSMutableDictionary *myFriend;

- (IBAction)back:(id)sender;
- (IBAction)sendMessage:(id)sender;

@end
