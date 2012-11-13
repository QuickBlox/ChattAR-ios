//
//  ChatViewController.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 3/27/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewTouch.h"
#import "AsyncImageView.h"
#import "CustomButtonWithQuote.h"
#import "WebViewController.h"
#import "MessagesViewController.h"
#import "CustomSwitch.h"

#define tableIsUpdating 1011

@interface ChatViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate, UIScrollViewDelegate, FBServiceResultDelegate, UIWebViewDelegate>{
    UIImage *messageBGImage;
    UIImage *messageBGImage2;
    UIImage *distanceImage;
    UIImage *distanceImage2;
    
    ViewTouch *backView;
	int page;

	BOOL isLoadingMoreMessages;
    
    dispatch_queue_t getMoreMessagesWorkQueue;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) IBOutlet UITextField *messageField;
@property (nonatomic, retain) IBOutlet UITableView *messagesTableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *sendMessageActivityIndicator;

@property (nonatomic, retain) NSString* quoteMark;
@property (nonatomic, retain) AsyncImageView* quotePhotoTop;

- (IBAction)sendMessageDidPress:(id)sender;

- (void)refresh;

- (void)addQuote;

@end
