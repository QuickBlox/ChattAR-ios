//
//  FBChatViewController.m
//  Chattar
//
//  Created by Sonny Black on 22.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "FBChatViewController.h"
#import "WebViewController.h"
#import "AppDelegate.h"


#define VIEW_WIDTH    self.view.frame.size.width
#define VIEW_HEIGHT    self.view.frame.size.height

#define RESET_CHAT_BAR_HEIGHT    SET_CHAT_BAR_HEIGHT(kChatBarHeight1)
#define EXPAND_CHAT_BAR_HEIGHT    SET_CHAT_BAR_HEIGHT(kChatBarHeight4)
#define    SET_CHAT_BAR_HEIGHT(HEIGHT)\
CGRect chatContentFrame = _chatTableView.frame;\
chatContentFrame.size.height = VIEW_HEIGHT - HEIGHT;\
[UIView beginAnimations:nil context:NULL];\
[UIView setAnimationDuration:0.1f];\
_chatTableView.frame = chatContentFrame;\
chatBar.frame = CGRectMake(chatBar.frame.origin.x, chatContentFrame.size.height,\
VIEW_WIDTH, HEIGHT);\
[UIView commitAnimations]

#define BAR_BUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE\
style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define ClearConversationButtonIndex 0

// 15 mins between messages before we show the date
#define SECONDS_BETWEEN_MESSAGES        (60*15)

static CGFloat const kSentDateFontSize = 13.0f;
static CGFloat const kMessageFontSize   = 16.0f;   // 15.0f, 14.0f
static CGFloat const kMessageTextWidth  = 180.0f;
static CGFloat const kContentHeightMax  = 84.0f;  // 80.0f, 76.0f
static CGFloat const kChatBarHeight1    = 40.0f;
static CGFloat const kChatBarHeight4    = 94.0f;
#define messageWidth 235

@interface FBChatViewController ()

@end

@implementation FBChatViewController

@synthesize chatTableView = _chatTableView;
@synthesize chatHistory, emptyChat;

#pragma mark Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
	{
        // Custom initialization
		messageBGImageLeft = [[[UIImage imageFromResource:@"Grey_Bubble.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:13] retain];
        messageBGImageRight = [[[UIImage imageFromResource:@"Blue_Bubble.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:13] retain];
		self.hidesBottomBarWhenPushed = YES;
		
		emptyChat = [[UILabel alloc] init];
		
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	if (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPhone) {
        // Register notification when the keyboard will be show
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        // Register notification when the keyboard will be hide
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
		// Register input message
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:)
													 name:kNewChatMessageCome object:nil];
    }

    
	// set right button with user photo
    AsyncImageView *userPic = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    userPic.useMask = YES;
    [userPic setUserInteractionEnabled:YES];
    NSString *userID = [chatHistory.to objectForKey:kId]; 
    [userPic loadImageFromURL:[NSURL URLWithString: [[[DataManager shared].myFriendsAsDictionary objectForKey:userID] objectForKey:kPicture]]];
    //
    UIButton *rb = [UIButton buttonWithType:UIButtonTypeCustom];
    [rb setBackgroundColor:[UIColor clearColor]];
    [rb setFrame:CGRectMake(0,0,30,30)];
    [rb addSubview:userPic];
    [userPic release];
    [rb addTarget:self action:@selector(rightButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
    //
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithCustomView:rb];
    self.navigationItem.rightBarButtonItem = anotherButton;
    [anotherButton release];
    
    
    // Create chatBar
    chatBar = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height-kChatBarHeight1,
                                                            self.view.frame.size.width, kChatBarHeight1)];
    chatBar.clearsContextBeforeDrawing = NO;
    chatBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    chatBar.image = [[UIImage imageNamed:@"ChatBar.png"]
                     stretchableImageWithLeftCapWidth:18 topCapHeight:20];
    chatBar.userInteractionEnabled = YES;
    
    // Create chatInput.
    chatInput = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 9.0f, 234.0f, 22.0f)];
    chatInput.delegate = self;
    chatInput.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    chatInput.clearsContextBeforeDrawing = NO;
    chatInput.font = [UIFont systemFontOfSize:kMessageFontSize];
    chatInput.backgroundColor = [UIColor clearColor];
    [chatBar addSubview:chatInput];
    [chatInput release];
    //
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
    chatInput.leftViewMode = UITextFieldViewModeAlways;
    chatInput.leftView = paddingView;
    [paddingView release];
    
    // Create sendButton.
    sendButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    sendButton.clearsContextBeforeDrawing = NO;
    sendButton.frame = CGRectMake(chatBar.frame.size.width - 68.0f, 6.0f, 61.0f, 29.0f);
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | // multi-line input
    UIViewAutoresizingFlexibleLeftMargin;                       // landscape
    UIImage *sendButtonBackground = [UIImage imageNamed:@"sendButton.png"];
    [sendButton setBackgroundImage:sendButtonBackground forState:UIControlStateNormal];
    [sendButton setBackgroundImage:sendButtonBackground forState:UIControlStateDisabled];
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    sendButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    UIColor *shadowColor = [[UIColor alloc] initWithRed:0.325f green:0.463f blue:0.675f alpha:1.0f];
    [sendButton setTitleShadowColor:shadowColor forState:UIControlStateNormal];
    [shadowColor release];
    [sendButton addTarget:self action:@selector(sendMessage)
         forControlEvents:UIControlEventTouchUpInside];
    
    [chatBar addSubview:sendButton];
    
    [self.view addSubview:chatBar];
    [chatBar release];
	
    
	// set title
	[self setTitle:[chatHistory.to objectForKey:kName]];
	
    
    // scroll to bottom item
	if ([chatHistory.messages  count] > 0){
		[self performSelector:@selector(scrollToBottomAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.001];
	}
	else 
	{
		[emptyChat setFrame:CGRectMake(30, 60, 260, 45)];
		[emptyChat setFont:[UIFont fontWithName:@"system" size:13]];
		[emptyChat setNumberOfLines:0];
		[emptyChat setTextAlignment:UITextAlignmentCenter];
		[emptyChat setBackgroundColor:[UIColor clearColor]];
		[emptyChat setText:NSLocalizedString(@"There have been no dialogs with this user.", nil)];
		
		[self.view addSubview:emptyChat];
		[self.view bringSubviewToFront:emptyChat];
	}
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.chatTableView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:kNewChatMessageCome
												  object:nil];
    
    [super viewDidUnload];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // mark Conversation as read
    [self markConversationAsRead];
    
    // remove if empty
    if([chatHistory.messages count] == 0){
        [[DataManager shared].historyConversation removeObjectForKey:[chatHistory.to objectForKey:kId]];
		[[DataManager shared].historyConversationAsArray removeObject:chatHistory];
    }else if(isWriteAtLeastOneMessage){
        [[DataManager shared].historyConversationAsArray removeObject:chatHistory];
        [[DataManager shared].historyConversationAsArray insertObject:chatHistory atIndex:0];
    }
}

- (void) dealloc
{
	[messageBGImageLeft release];
	[messageBGImageRight release];
    
    [chatHistory release];
	
	[emptyChat release];
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)rightButtonDidPress:(id)sender
{
    // Show profile
	NSString *url = [NSString stringWithFormat:@"http://www.facebook.com/profile.php?id=%@", [chatHistory.to objectForKey:kId]];
    
    WebViewController *webViewControleler = [[WebViewController alloc] init];
    webViewControleler.urlAdress = url;
	[self.navigationController pushViewController:webViewControleler animated:YES];
    [webViewControleler autorelease];
}

- (void)touchOnView:(UIView *)view
{
    [chatInput resignFirstResponder];
}

- (void)scrollToBottomAnimated:(BOOL)animated 
{
	NSInteger bottomRow;
	if (chatHistory != nil)
	{
		bottomRow = [chatHistory.messages count] - 1;
		if (bottomRow >= 0) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:bottomRow inSection:0];
			[_chatTableView reloadData];
			[_chatTableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
		}
	}
}

- (void)clearChatInput {
    chatInput.text = @"";
    [self scrollToBottomAnimated:YES];       
}

- (void)markConversationAsRead{
    //
    // -- badge
    if(chatHistory.isUnRead){
        UITabBarController *tabBarController = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).tabBarController;
        int badge = [((UITabBarItem *)[tabBarController.tabBar.items objectAtIndex:0]).badgeValue intValue];
        --badge;
        if(badge <= 0){
            // set badge
            ((UITabBarItem *)[tabBarController.tabBar.items objectAtIndex:0]).badgeValue = nil;
        }else{
            // set badge
            ((UITabBarItem *)[tabBarController.tabBar.items objectAtIndex:0]).badgeValue = [NSString stringWithFormat:@"%d", badge];
        }
        
        chatHistory.isUnRead = NO;
    }
}


#pragma mark -
#pragma mark UITextFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textView
{
	[backView removeFromSuperview];
    backView = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [chatHistory.messages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    float cellHeight;
    
    // text
    NSString *messageText = [[chatHistory.messages objectAtIndex:indexPath.row] objectForKey:kMessage];
    //
    CGSize boundingSize = CGSizeMake(messageWidth-20, 10000000);
    CGSize itemTextSize = [messageText sizeWithFont:[UIFont systemFontOfSize:15]
								  constrainedToSize:boundingSize
									  lineBreakMode:UILineBreakModeWordWrap];
    
    // plain text
    cellHeight = itemTextSize.height;
	
    return cellHeight + 28;
}

//// determine date of message
//NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//[dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'+0000'"];
//NSDate *dateFromString = [dateFormatter dateFromString:dateInterval];
//[dateFormatter release];
//
//NSString *dateVal;
//if ([dateFromString timeIntervalSinceNow] > -86400){
//    dateVal = NSLocalizedString(@"Today", nil);
//}else if (([dateFromString timeIntervalSinceNow] < -86400) && ([dateFromString timeIntervalSinceNow] > -172800)){
//    dateVal = NSLocalizedString(@"Yesterday", nil);
//}else{
//    dateVal = [[dateFromString description] substringToIndex:10];
//}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	NSString *messageText = [[chatHistory.messages objectAtIndex:indexPath.row] objectForKey:kMessage];
	
	UIImageView *messageBGView;
    UILabel *userMessage;
    UILabel *datetime;

    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setBackgroundColor:[UIColor clearColor]];
		
		// background cloud
        messageBGView = [[UIImageView alloc] init];
        messageBGView.tag = 1102;
        messageBGView.userInteractionEnabled = YES;
        [cell.contentView addSubview:messageBGView];
        [messageBGView release];
		
		// user message
        userMessage = [[UILabel alloc] init];
        userMessage.tag = 1103;
        [userMessage setFont:[UIFont systemFontOfSize:15]];
        userMessage.numberOfLines = 0;
        [userMessage setBackgroundColor:[UIColor clearColor]];
        [messageBGView addSubview:userMessage];
        [userMessage release];
		
		// datetime
        datetime = [[UILabel alloc] init];
        datetime.tag = 1104;
        [datetime setTextAlignment:UITextAlignmentCenter];
        datetime.numberOfLines = 2;
        [datetime setFont:[UIFont systemFontOfSize:11]];
        [datetime setBackgroundColor:[UIColor clearColor]];
        [datetime setTextColor:[UIColor grayColor]];
        [cell.contentView addSubview:datetime];
        [datetime release];
		
	}else{
		messageBGView = (UIImageView *)[cell.contentView viewWithTag:1102];
		userMessage = (UILabel *)[messageBGView viewWithTag:1103];
		datetime = (UILabel *)[cell.contentView viewWithTag:1104];
		
	}
	
	// set datetime
    NSString *dateInterval = [[chatHistory.messages objectAtIndex:indexPath.row] objectForKey:kCreatedTime];
	if(![dateInterval isEqualToString:@"N.A."])
	{
		// determine date of message
		dateInterval = [dateInterval substringFromIndex:11];
		dateInterval = [dateInterval substringToIndex:[dateInterval length] - 8];
		datetime.text = dateInterval;
	}
	else 
	{
		datetime.text = @"N.A.";
	}
	
	// left or rigth cell
    BOOL isLeftCell = NO;
	NSString *rightCell= [[[chatHistory.messages objectAtIndex:indexPath.row] objectForKey:kFrom] objectForKey:kId];
		
	if ([rightCell isEqualToString:[DataManager shared].currentFBUserId]){
		isLeftCell = YES;
	}
    
    // get height
    CGSize boundingSize = CGSizeMake(messageWidth-20, 10000000);
    CGSize itemTextSize = [messageText sizeWithFont:[UIFont systemFontOfSize:15]
                                  constrainedToSize:boundingSize
                                      lineBreakMode:UILineBreakModeWordWrap];
    
    // cell height
    float textHeight = itemTextSize.height + 7;
    float cellHeight = itemTextSize.height;
	
	
	float messageTextWidth;

	if (isLeftCell){
		// set message label
		[userMessage setFrame:CGRectMake(15, 6, messageWidth - 20, textHeight-10)];
		userMessage.text = messageText;
		[userMessage sizeToFit];
		
		// datetime
		[datetime setFrame:CGRectMake(userMessage.frame.size.width + 30, userMessage.frame.size.height - 10, 40, 30)];
	}else{
		// set message label
		[userMessage setFrame:CGRectMake(10, 6, messageWidth - 20, textHeight-10)];
		userMessage.text = messageText; 
		[userMessage sizeToFit];
		
		// datetime
		[datetime setFrame:CGRectMake(320 - userMessage.frame.size.width - 70, userMessage.frame.size.height - 10, 40, 30)];
	}
	
	messageTextWidth = userMessage.frame.size.width;

	
	// left/right messages
    if(isLeftCell){
        
        // set cloud view (left)
        [messageBGView setImage:messageBGImageLeft];
        [messageBGView setFrame:CGRectMake(5, 6, messageTextWidth + 25, cellHeight + 15)];
	}else{
        
        // set cloud view (right)
        [messageBGView setImage:messageBGImageRight];
        [messageBGView setFrame:CGRectMake(70 + 220 - messageTextWidth , 6, messageTextWidth+25, cellHeight+15)];
	}
	
    return cell;
}


#pragma mark - 
#pragma mark Keyboard 

-(void) keyboardWillShow:(NSNotification *)note
{
	[self resizeViewWithOptions:[note userInfo]];
}

-(void) keyboardWillHide:(NSNotification *)note
{
	[self resizeViewWithOptions:[note userInfo]];
}

- (void)resizeViewWithOptions:(NSDictionary *)options
{  
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    [[options objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[options objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[options objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    CGRect viewFrame = self.view.frame;

    CGRect keyboardFrameEndRelative = [self.view convertRect:keyboardEndFrame fromView:nil];
	
    viewFrame.size.height =  keyboardFrameEndRelative.origin.y;
    self.view.frame = viewFrame;
    [UIView commitAnimations];
    
    [self scrollToBottomAnimated:YES];
    
	if(backView == nil){
        backView = [[ViewTouch alloc] initWithFrame:CGRectMake(0, 0, 320, 154) selector:@selector(touchOnView:) target:self];
        [self.view addSubview:backView];
        [backView release];
    }
}


#pragma mark - 
#pragma mark Messages 

- (void)sendMessage 
{
	NSString *rightTrimmedMessage =[chatInput.text stringByTrimmingTrailingWhitespaceAndNewlineCharacters];
    
    // Don't send blank messages.
    if (rightTrimmedMessage.length == 0) {
        [self clearChatInput];
        return;
    }
	
	// send to Facebook
	[[FBService shared] sendMessageToFacebook:rightTrimmedMessage 
                         withFriendFacebookID:[chatHistory.to objectForKey:kId]]; 

	
	[self clearChatInput];
	
	// add message to cache
    //
	NSMutableDictionary *newMessage = [[NSMutableDictionary alloc] init];
	
	//get current date of sended message
	NSDate *now = [NSDate date];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
	[formatter setLocale:[NSLocale currentLocale]];
	NSString *timeStamp = [formatter stringFromDate:now];
    [formatter release];
	
	//add date of message
	[newMessage setObject:timeStamp forKey:kCreatedTime];
	
	//add own id 
	NSMutableDictionary *tempID = [[NSMutableDictionary alloc] init];
	[tempID setObject:[[DataManager shared] currentFBUserId] forKey:kId];
	[tempID setObject:@"me" forKey:kName];
	[newMessage setObject:tempID forKey:kFrom];
	[tempID release];

	//add message
	[newMessage setObject:rightTrimmedMessage forKey:kMessage];
	
	//add message to cache
    [chatHistory.messages addObject:newMessage];
    [newMessage release];

	[emptyChat removeFromSuperview];
	
    // If user offline -> send push
    NSDictionary *toUser = [[DataManager shared].myFriendsAsDictionary objectForKey:[chatHistory.to objectForKey:kId]];
    if([[toUser objectForKey:kOnOffStatus] intValue] == 0){
        // get QB User for send push
        [QBUsers userWithFacebookID:[chatHistory.to objectForKey:kId] delegate:self context:rightTrimmedMessage];
    }
	
	[self scrollToBottomAnimated:YES];
    
    isWriteAtLeastOneMessage = YES;
}

- (void)messageReceived:(NSNotification*)textMessage 
{
	[self scrollToBottomAnimated:YES];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

-(void)completedWithResult:(Result *)result{
}

-(void)completedWithResult:(Result *)result context:(void *)contextInfo{
	if (result.success){
        // User info result
		if ([result isKindOfClass:QBUUserResult.class]){
			QBUUserResult* _result = (QBUUserResult*)result;
			
			// Create message
			NSString *mesage = [NSString stringWithFormat:@"Chattar. %@: %@", [[DataManager shared].currentFBUser objectForKey:kName], (NSString *)contextInfo];
			//
			NSMutableDictionary *payload = [NSMutableDictionary dictionary];
			NSMutableDictionary *aps = [NSMutableDictionary dictionary];
			[aps setObject:@"default" forKey:QBMPushMessageSoundKey];
			[aps setObject:mesage forKey:QBMPushMessageAlertKey];
			[payload setObject:aps forKey:QBMPushMessageApsKey];
			//
			QBMPushMessage *message = [[QBMPushMessage alloc] initWithPayload:payload];
			
            BOOL isDevEnv = NO;
#ifdef DEBUG
            isDevEnv = YES;
#endif
            
			// Send push
			[QBMessages TSendPush:message
								 toUsers:[NSString stringWithFormat:@"%d", _result.user.ID]
				  isDevelopmentEnvironment:isDevEnv
								delegate:self];
            
            [message release];
		}
	}
}


@end
