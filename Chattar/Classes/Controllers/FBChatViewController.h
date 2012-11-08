//
//  FBChatViewController.h
//  ChattAR for facebook
//
//  Created by QuickBlox developers on 22.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "ViewTouch.h"


@interface FBChatViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, 
    UITextFieldDelegate, QBActionStatusDelegate>
{
	// cloud for message view
    UIImage *messageBGImageLeft;
    UIImage *messageBGImageRight;
	
	// back view for hide keyboard
    ViewTouch *backView;
    
    // chat bar
    UIImageView *chatBar;
    UITextField *chatInput;
    UIButton *sendButton;
    
    BOOL isWriteAtLeastOneMessage;
}

@property (retain, nonatomic) IBOutlet UITableView	*chatTableView;
@property (retain, nonatomic) Conversation *chatHistory;
@property (nonatomic, retain) UILabel* emptyChat;
@property (nonatomic, retain) UIButton *rightButton;

// quickblox quieries cancelables
@property (nonatomic, retain) id<Cancelable> getFBUserQuery;

- (void)markConversationAsRead;

@end
