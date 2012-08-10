//
//  ChatViewController.h
//  Fbmsg
//
//  Created by Igor Khomenko on 3/27/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewTouch.h"
#import "AsyncImageView.h"
#import "CustomButtonWithQuote.h"
#import "WebViewController.h"
#import "MessagesViewController.h"
#import "CustomSwitch.h"


@interface ChatViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ActionStatusDelegate, UIScrollViewDelegate, FBServiceResultDelegate>{
    UIImage *messageBGImage;
    
    ViewTouch *backView;
	int page;

	BOOL isLoadingMoreMessages;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) IBOutlet UITextField *messageField;
@property (nonatomic, retain) IBOutlet UITableView *messagesTableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *sendMessageActivityIndicator;

@property (nonatomic, retain) NSString* quoteMark;
@property (nonatomic, retain) AsyncImageView* quotePhotoTop;

- (IBAction)sendMessageDidPress:(id)sender;

- (void)refresh;
- (void)addPoints:(NSArray *)mapPoints;

- (void)addQuote;

@end
