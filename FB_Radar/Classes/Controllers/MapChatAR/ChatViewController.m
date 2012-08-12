//
//  ChatViewController.m
//  Fbmsg
//
//  Created by Igor Khomenko on 3/27/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#define messageWidth 250
#define getMoreChatMessages @"getMoreChatMessages"
#define getQuotedId			@"getQuotedId"

#import "ChatViewController.h"
#import "MapChatARViewController.h"
#import "ARMarkerView.h"
#import "TestManager.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

@synthesize messageField, messagesTableView, sendMessageActivityIndicator;
@synthesize quoteMark, quotePhotoTop;
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    messageField.leftViewMode = UITextFieldViewModeAlways;
    messageField.leftView = paddingView;
    [paddingView release];
    
    // message bubble
    messageBGImage = [[[UIImage imageNamed:@"cellBodyBG.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:22] retain];
    messageBGImage2 = [[[UIImage imageNamed:@"cellBodyBG2.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:22] retain];
    
    distanceImage = [[UIImage imageNamed:@"kmBG.png"] retain];
    distanceImage2 = [[UIImage imageNamed:@"kmBG2.png"] retain];

    // current page of geodata
    page = 1;
	
    // YES when is getting new messages
	isLoadingMoreMessages = NO;
}

- (void)removeQuote
{
    messageField.rightView = nil;
    quotePhotoTop = nil;
	self.quoteMark = nil;
    
    [messageField resignFirstResponder];
}

- (void)viewDidUnload
{
    self.messageField = nil;
    self.messagesTableView = nil;
    self.sendMessageActivityIndicator = nil;

    [messageBGImage release];
    messageBGImage = nil;
    [messageBGImage2 release];
    messageBGImage2 = nil;
    [distanceImage release];
    distanceImage = nil;
    [distanceImage2 release];
    distanceImage2 = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[messagesTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)sendMessageDidPress:(id)sender{
    // check for empty
    if ([[messageField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        return;
    }    
    
    // remove | symbol
    messageField.text = [messageField.text  stringByReplacingOccurrencesOfString:@"|" withString:@""];

	QBLGeoData *geoData = [QBLGeoData currentGeoData];
#ifdef DEBUG
    NSArray *coord = [[TestManager shared].testLocations objectForKey:[DataManager shared].currentFBUserId];
    if(coord != nil){
        geoData.latitude = (CLLocationDegrees)[[coord objectAtIndex:0] doubleValue];
        geoData.longitude = (CLLocationDegrees)[[coord objectAtIndex:1] doubleValue];
    }
#endif
	geoData.user = [DataManager shared].currentQBUser;
    
    geoData.latitude = 32.0;
    geoData.longitude = -40.0;
	
    // set body - with quote or without
	if (quoteMark){
		geoData.status = [quoteMark stringByAppendingString:messageField.text];
	}else {
		geoData.status = messageField.text;
	}

    // post geodata
	[QBLocationService createGeoData:geoData delegate:self];

    [sendMessageActivityIndicator startAnimating];
    

	// send push notification if this is quote
	if (quoteMark){
		// Create message
        //
        NSMutableDictionary *payload = [NSMutableDictionary dictionary];
        NSMutableDictionary *aps = [NSMutableDictionary dictionary];
        [aps setObject:@"default" forKey:QBMPushMessageSoundKey];
        [aps setObject:quotePushMessageInChat forKey:QBMPushMessageAlertKey];
        [payload setObject:aps forKey:QBMPushMessageApsKey];
        //
        QBMPushMessage *message = [[QBMPushMessage alloc] initWithPayload:payload];
		
        BOOL isDevEnv = NO;
#ifdef DEBUG
        isDevEnv = YES;
#endif
        
        // Send push
        [QBMessagesService TSendPush:message
                              toUsers:[NSString stringWithFormat:@"%d",  messageField.rightView.tag] 
               environmentDevelopment:isDevEnv 
                             delegate:self];
	}
    
    if(quotePhotoTop){
        [quotePhotoTop removeFromSuperview];
        quotePhotoTop = nil;
    }else{
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        messageField.rightViewMode = UITextFieldViewModeAlways;
        messageField.rightView = view;
        [view release];
    }

	self.quoteMark = nil;
}

- (void)addQuote
{
    // pattern
    // @fbid=<FB_id>@name=<user_name>@date=<created_at>@photo=<url>@msg=<text>|<message_text>
    //
    
    NSString *userStatus = [(MapChatARViewController *)delegate selectedUserAnnotation].userStatus;
    
    NSString *text = [[DataManager shared] originMessageFromQuote:userStatus];
	
    NSDate* date = [(MapChatARViewController *)delegate selectedUserAnnotation].createdAt;
    NSString* authorName = [(MapChatARViewController *)delegate selectedUserAnnotation].userName;
    NSString* photoLink = [[(MapChatARViewController *)delegate selectedUserAnnotation].fbUser objectForKey:kPicture];
    NSString* fbid = [(MapChatARViewController *)delegate selectedUserAnnotation].fbUserId;
	
    
    self.quoteMark = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@", fbidIdentifier, fbid,nameIdentifier, authorName, dateIdentifier, date, photoIdentifier, photoLink, messageIdentifier, text, @"|"];
    
    
    
    // add Quote user photo
	quotePhotoTop = [[AsyncImageView alloc] initWithFrame:CGRectMake(-2, 0, 18, 18)];
	UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeQuote)];
	[quotePhotoTop addGestureRecognizer:recognizer];
    quotePhotoTop.clipsToBounds = YES;
    quotePhotoTop.layer.cornerRadius = 2;
	[recognizer release];
	UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	[view addSubview:quotePhotoTop];
    [quotePhotoTop release];
	messageField.rightViewMode = UITextFieldViewModeAlways;
	messageField.rightView = view;
	[view release];
    
	[quotePhotoTop loadImageFromURL:[NSURL URLWithString:photoLink]];
    // set id for push
    messageField.rightView.tag = [(MapChatARViewController *)delegate selectedUserAnnotation].qbUserID; 
}

- (void)refresh{

    // add new
    // sort chat messaged due to created date
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey: @"createdAt" ascending: NO] autorelease];
	NSArray* sortedArray = [[(MapChatARViewController *)delegate chatPoints] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

	[[(MapChatARViewController *)delegate chatPoints] removeAllObjects];
	[[(MapChatARViewController *)delegate chatPoints] addObjectsFromArray:sortedArray];
	
	messagesTableView.delegate = self;
    messagesTableView.dataSource = self;
    [messagesTableView reloadData];
    [messagesTableView setUserInteractionEnabled:YES];
    
	isLoadingMoreMessages = NO;
}

- (void)getMoreMessages
{
	++page;
	
	// get points for chat
	QBLGeoDataGetRequest *searchChatMessagesRequest = [[QBLGeoDataGetRequest alloc] init];
	searchChatMessagesRequest.perPage = kGetGeoDataCount; // Pins limit for each page
	searchChatMessagesRequest.page = page;
	searchChatMessagesRequest.status = YES;
	searchChatMessagesRequest.sortBy = GeoDataSortByKindCreatedAt;
	[QBLocationService geoDataWithRequest:searchChatMessagesRequest delegate:self context:getMoreChatMessages];
	[searchChatMessagesRequest release];
}


- (void)didSelectedQuote:(CustomButtonWithQuote *)sender
{
    UserAnnotation *annotation = [[UserAnnotation alloc] init];
    
    annotation.fbUserId = [sender.quote objectForKey:kFbID];
    annotation.fbUser = [NSDictionary dictionaryWithObjectsAndKeys:[sender.quote objectForKey:kName], kName, [sender.quote objectForKey:kFbID], kId, [sender.quote objectForKey:kPhoto], kPicture, nil];
    annotation.userStatus = [sender.quote objectForKey:kMessage];
    annotation.userName = [sender.quote objectForKey:kName];
    annotation.createdAt = [sender.quote objectForKey:kDate];
   // annotation.qbUserID = [DataManager

    ((MapChatARViewController *)delegate).selectedUserAnnotation = annotation;
    [annotation release];
    
    // show action sheet
    [((MapChatARViewController *)delegate) showActionSheetWithTitle:annotation.userName andSubtitle:annotation.userStatus];
}

// switch All/Friends
- (void)allFriendsSwitchValueDidChanged:(id)sender{
    [((MapChatARViewController *)delegate) allFriendsSwitchValueDidChanged:sender];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    // show back view
    if(backView == nil){
        backView = [[ViewTouch alloc] initWithFrame:CGRectMake(0, 44, 320, 154) selector:@selector(touchOnView:) target:self];
        [self.view addSubview:backView];
        [backView release];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [backView removeFromSuperview];
    backView = nil;
}

- (void)touchOnView:(UIView *)view{
    [messageField resignFirstResponder];
}


#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserAnnotation *currentAnnotation = [[(MapChatARViewController *)delegate chatPoints] objectAtIndex:[indexPath row]];
    
    // regular chat cell
	if ([currentAnnotation isKindOfClass:[UserAnnotation class]]){
		CGSize boundingSize = CGSizeMake(messageWidth-25, 10000000);
		
		CGSize itemFrameSize = [currentAnnotation.userStatus sizeWithFont:[UIFont systemFontOfSize:14]
								constrainedToSize:boundingSize
									lineBreakMode:UILineBreakModeWordWrap];
		
		if(itemFrameSize.height < 50){
			itemFrameSize.height = 50;
		}
		
        // if quote
		if ([currentAnnotation.quotedUserName length]){
			return itemFrameSize.height + 95;
		}
		
		return itemFrameSize.height + 45;
	
    // get more chat messages cell
    }else {
		return 60;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[(MapChatARViewController *)delegate chatPoints] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *friendsIds = [[DataManager shared].myFriendsAsDictionary allKeys];
                                  
    UserAnnotation *currentAnnotation = [[(MapChatARViewController *)delegate chatPoints] objectAtIndex:[indexPath row]];
    
    if ([currentAnnotation isKindOfClass:[UITableViewCell class]]){
		return (UITableViewCell*)currentAnnotation;
	}

    // get height
    CGSize boundingSize = CGSizeMake(messageWidth-25, 10000000);
    
    CGSize itemFrameSize = [currentAnnotation.userStatus sizeWithFont:[UIFont systemFontOfSize:14]
                                             constrainedToSize:boundingSize
                                                 lineBreakMode:UILineBreakModeWordWrap];
    float textHeight = itemFrameSize.height + 7;
    
    static NSString *reuseIdentifier = @"ChatMessageCell";
    
    // create cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    AsyncImageView *userPhoto;
    UIImageView *messageBGView;
    UIImageView *distanceView;
    UILabel *distanceLabel;
    UILabel *userMessage;
    UILabel *userName;
    UILabel *datetime;
    CustomButtonWithQuote* quoteBG;
    AsyncImageView* quotedUserPhoto;
    UILabel* quotedMessageDate;
    UILabel* quotedMessageText;
    UILabel* quotedUserName;
    UIImageView* replyArrow;
    
    if(cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // quoted user's photo
        quotedUserPhoto = [[AsyncImageView alloc] init];
        quotedUserPhoto.layer.masksToBounds = YES;
        quotedUserPhoto.userInteractionEnabled =YES;
        quotedUserPhoto.tag = 1109;
        quotedUserPhoto.hidden = YES;
        [cell.contentView addSubview:quotedUserPhoto];
        [quotedUserPhoto release];
        
        // quoted message's creation date
        quotedMessageDate = [[UILabel alloc] init];
        quotedMessageDate.hidden = YES;
        quotedMessageDate.tag = 1111;
        [quotedMessageDate setTextAlignment:UITextAlignmentRight];
        [quotedMessageDate setFont:[UIFont systemFontOfSize:11]];
        [quotedMessageDate setTextColor:[UIColor grayColor]];
        quotedMessageDate.numberOfLines = 1;
        [quotedMessageDate setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:quotedMessageDate];
        [quotedMessageDate release];
//        quotedMessageDate.layer.borderWidth = 1;
//        quotedMessageDate.layer.borderColor = [[UIColor redColor] CGColor];
        
        // quoted user name
        quotedUserName = [[UILabel alloc] init];
        quotedUserName.tag = 1112;
        quotedUserName.hidden = YES;
        [quotedUserName setFont:[UIFont boldSystemFontOfSize:11]];
        [quotedUserName setBackgroundColor:[UIColor clearColor]];
        [quotedUserName setTextColor:[UIColor grayColor]];
        [cell.contentView addSubview:quotedUserName];
        [quotedUserName release];
//        quotedUserName.layer.borderWidth = 1;
//        quotedUserName.layer.borderColor = [[UIColor redColor] CGColor];
        
        //
        // user photo
        userPhoto = [[AsyncImageView alloc] init];
        userPhoto.layer.masksToBounds = YES;
        userPhoto.userInteractionEnabled =YES;
        userPhoto.tag = 1101;
        [cell.contentView addSubview:userPhoto];
        [userPhoto release];
        
        // distance BG
        if([friendsIds containsObject:[currentAnnotation.fbUser objectForKey:kId]])
        {
            distanceView = [[UIImageView alloc] initWithImage:distanceImage];
        }
        else
        {
            distanceView = [[UIImageView alloc] initWithImage:distanceImage2];
        }
        distanceView.layer.masksToBounds = YES;
        distanceView.userInteractionEnabled = YES;
        distanceView.tag = 1106;
        [cell.contentView addSubview:distanceView];
        [distanceView release];
        
        // distance label
        distanceLabel = [[UILabel alloc] init];
        distanceLabel.tag = 1107;
        [distanceLabel setFont:[UIFont boldSystemFontOfSize:12]];
        distanceLabel.numberOfLines = 1;
        [distanceLabel setBackgroundColor:[UIColor clearColor]];
        [distanceLabel setTextColor:[UIColor whiteColor]];
        [distanceLabel setTextAlignment:UITextAlignmentCenter];
        [cell.contentView addSubview:distanceLabel];
        [distanceLabel release];
        
        // user message
        //
        // background
        
        messageBGView = [[UIImageView alloc] init];
        messageBGView.tag = 1102;
        
        if([friendsIds containsObject:[currentAnnotation.fbUser objectForKey:kId]])
        {
             [messageBGView setImage:messageBGImage];
        }
        else
        {
            [messageBGView setImage:messageBGImage2];
        }
        
         messageBGView.userInteractionEnabled =YES;
        [cell.contentView addSubview:messageBGView];
        [messageBGView release];
        //
        // label
        userMessage = [[UILabel alloc] init];
        userMessage.tag = 1103;
        [userMessage setFont:[UIFont systemFontOfSize:14]];
        userMessage.numberOfLines = 0;
        [userMessage setBackgroundColor:[UIColor clearColor]];
        [messageBGView addSubview:userMessage];
        [userMessage release];
//        userMessage.layer.borderWidth = 1;
//        userMessage.layer.borderColor = [[UIColor redColor] CGColor];
        
        
        // datetime
        datetime = [[UILabel alloc] init];
        datetime.tag = 1104;
        [datetime setTextAlignment:UITextAlignmentRight];
        datetime.numberOfLines = 1;
        [datetime setFont:[UIFont systemFontOfSize:11]];
        [datetime setBackgroundColor:[UIColor clearColor]];
        [datetime setTextColor:[UIColor grayColor]];
        [cell.contentView addSubview:datetime];
        [datetime release];
//        datetime.layer.borderWidth = 1;
//        datetime.layer.borderColor = [[UIColor redColor] CGColor];
//        
        // label
        userName = [[UILabel alloc] init];
        userName.tag = 1105;
        [userName setFont:[UIFont boldSystemFontOfSize:11]];
        [userName setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:userName];
        [userName release];
//        userName.layer.borderWidth = 1;
//        userName.layer.borderColor = [[UIColor redColor] CGColor];
        
        // quote BG
        quoteBG = [[CustomButtonWithQuote alloc] init];
        [quoteBG setBackgroundImage:[UIImage imageNamed:@"replyCellBodyBG.png"] forState:UIControlStateNormal];
        [quoteBG setBackgroundImage:[UIImage imageNamed:@"replyCellBodyBG_Pressed.png"] forState:UIControlStateHighlighted];
        quoteBG.tag = 1108;
        [quoteBG addTarget:self action:@selector(didSelectedQuote:) forControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchUpInside];
        quoteBG.hidden = YES;
        [cell.contentView addSubview:quoteBG];
        [quoteBG release];
        
        // quoted message
        quotedMessageText = [[UILabel alloc] init];
        quotedMessageText.tag = 1110;
        quotedMessageText.hidden = YES;
        [quotedMessageText setFont:[UIFont systemFontOfSize:13]];
        [quotedMessageText setTextColor:[UIColor grayColor]];
        quotedMessageText.numberOfLines = 1;
        [quotedMessageText setBackgroundColor:[UIColor clearColor]];
        [quoteBG addSubview:quotedMessageText];
        [quotedMessageText release];
//        quotedMessageText.layer.borderWidth = 1;
//        quotedMessageText.layer.borderColor = [[UIColor redColor] CGColor];
        
        // add replay arroy
        replyArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"replyArrow.png"]];
        replyArrow.tag = 1113;
        replyArrow.userInteractionEnabled = YES;
        replyArrow.hidden = YES;
        [cell.contentView addSubview:replyArrow];
        [replyArrow release];

    }else{
        userPhoto = (AsyncImageView *)[cell.contentView viewWithTag:1101];
        messageBGView = (UIImageView *)[cell.contentView viewWithTag:1102];
        userMessage = (UILabel *)[messageBGView viewWithTag:1103];
        datetime = (UILabel *)[cell.contentView viewWithTag:1104];
        userName = (UILabel *)[cell.contentView viewWithTag:1105];
        distanceView = (UIImageView*)[cell.contentView viewWithTag:1106];
        distanceLabel = (UILabel*)[cell.contentView viewWithTag:1107];
        quoteBG = (CustomButtonWithQuote*)[cell.contentView viewWithTag:1108];
        quotedUserPhoto = (AsyncImageView*)[cell.contentView viewWithTag:1109];
        quotedMessageText = (UILabel*)[cell.contentView viewWithTag:1110];
        quotedMessageDate = (UILabel*)[cell.contentView viewWithTag:1111];
        quotedUserName = (UILabel*)[cell.contentView viewWithTag:1112];
        replyArrow = (UIImageView*)[cell.contentView viewWithTag:1113];
        
        if([friendsIds containsObject:[currentAnnotation.fbUser objectForKey:kId]])
        {
            [messageBGView setImage:messageBGImage];
            [distanceView setImage:distanceImage];
        }
        else
        {
            [messageBGView setImage:messageBGImage2];
            [distanceView setImage:distanceImage2];
        }
    }
    
    int shift = 0;
    
    // hide quote views
    if ([currentAnnotation.quotedUserName length]){
        quoteBG.hidden = NO;
        quotedUserName.hidden = NO;
        quotedMessageDate.hidden = NO;
        quotedMessageText.hidden = NO;
        quotedUserPhoto.hidden = NO;
        replyArrow.hidden = NO;
        
        shift = 50;
    }else{
        quoteBG.hidden = YES;
        quotedUserName.hidden = YES;
        quotedMessageDate.hidden = YES;
        quotedMessageText.hidden = YES;
        quotedUserPhoto.hidden = YES;
        replyArrow.hidden = YES;
    }
    
    
    
    // set user photo
    [userPhoto setFrame:CGRectMake(5, 5+shift, 50, 50)];
    [userPhoto loadImageFromURL:[NSURL URLWithString:currentAnnotation.userPhotoUrl]];
    
    // set distance bg
    [distanceView setFrame:CGRectMake(5, userPhoto.frame.origin.y+userPhoto.frame.size.height, 50, 25)];
    
    // distance label
    [distanceLabel setFrame:CGRectMake(5, distanceView.frame.origin.y+5, 50, 15)];
    if ([[DataManager shared].currentFBUserId isEqualToString:[currentAnnotation.fbUser objectForKey:kId]])
    {
        distanceLabel.hidden = YES;
        distanceView.hidden = YES;
        
        [messageBGView setImage:messageBGImage];

    }else{
        distanceLabel.hidden = NO;
        distanceView.hidden = NO;
        
        if (currentAnnotation.distance > 1000)
        {
            distanceLabel.text = [NSString stringWithFormat:@"%i km", currentAnnotation.distance/1000];
        }
        else 
        {
            distanceLabel.text = [NSString stringWithFormat:@"%i m", currentAnnotation.distance];
        }
    }

    // set bg
    [messageBGView setFrame:CGRectMake(62, 5+shift, messageWidth, textHeight+19)];
    
    // set message
    [userMessage setFrame:CGRectMake(21, 22, messageBGView.frame.size.width-25, messageBGView.frame.size.height-10)];
    userMessage.text = currentAnnotation.userStatus; 
    [userMessage sizeToFit];
    
    // datetime
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: currentAnnotation.createdAt];
    NSDate* firstDate = [NSDate dateWithTimeInterval: seconds sinceDate: currentAnnotation.createdAt];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"d MMMM HH:mm"];
    datetime.text = [formatter stringFromDate:firstDate];
    
    [datetime setFrame:CGRectMake(messageWidth-41, 11+shift, 101, 12)];
    
    // set user name
    [userName setFrame:CGRectMake(83, 10+shift, 125, 12)];
    userName.text = currentAnnotation.userName;
    
    // set quote BG
    [quoteBG setFrame:CGRectMake(messageBGView.frame.origin.x+15, 5, 250, 70)];
    [cell.contentView insertSubview:quoteBG belowSubview:messageBGView];
    //
    if (currentAnnotation.quotedUserFBId){
        [quoteBG.quote setObject:currentAnnotation.quotedUserFBId forKey:kFbID];
    }
    if (currentAnnotation.quotedUserName){
        [quoteBG.quote setObject:currentAnnotation.quotedUserName forKey:kName];
    }
    if (currentAnnotation.quotedMessageText){
        [quoteBG.quote setObject:currentAnnotation.quotedMessageText forKey:kMessage];
    }
    if (currentAnnotation.quotedUserPhotoURL){
        [quoteBG.quote setObject:currentAnnotation.quotedUserPhotoURL forKey:kPhoto];
    }
    if (currentAnnotation.quotedMessageDate){
        [quoteBG.quote setObject:currentAnnotation.quotedMessageDate forKey:kDate];
    }
    
    // set quoted user's photo
    [quotedUserPhoto setFrame:CGRectMake(quoteBG.frame.origin.x+22, quoteBG.frame.origin.y+8, 20, 20)];
    [cell.contentView bringSubviewToFront:quotedUserPhoto];
    if ([currentAnnotation.quotedUserPhotoURL length]){
        [quotedUserPhoto loadImageFromURL:[NSURL URLWithString:currentAnnotation.quotedUserPhotoURL]];
    }
    
    // set date of quoted message
    [quotedMessageDate setFrame:CGRectMake(messageWidth-30, quoteBG.frame.origin.y+12, 90, 12)];
    
    NSTimeZone *qtz = [NSTimeZone defaultTimeZone];
    NSInteger qseconds = [qtz secondsFromGMTForDate: currentAnnotation.quotedMessageDate];
    NSDate* qfirstDate = [NSDate dateWithTimeInterval: qseconds sinceDate: currentAnnotation.quotedMessageDate];
    
    NSDateFormatter* qformatter = [[NSDateFormatter alloc] init];
	[qformatter setLocale:[NSLocale currentLocale]];
    [qformatter setDateFormat:@"d MMMM HH:mm"];
    
    quotedMessageDate.text = [qformatter stringFromDate:qfirstDate];
    [cell.contentView bringSubviewToFront:quotedMessageDate];
    
    // set quoted user name
    [quotedUserName setFrame:CGRectMake(quotedUserPhoto.frame.origin.x+26, quotedUserPhoto.frame.origin.y+5, 95, 12)];
    quotedUserName.text = currentAnnotation.quotedUserName;
    [cell.contentView bringSubviewToFront:quotedUserName];
    
    // set quoted message's text
    [quotedMessageText setFrame:CGRectMake(22, quoteBG.frame.origin.y+25, 200, 20)];
    quotedMessageText.text = currentAnnotation.quotedMessageText;
    
    // add reply arrow
    [replyArrow setFrame:CGRectMake(72, 24, 11, 14)];
    [cell.contentView bringSubviewToFront:replyArrow];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.tag = [indexPath row];
    [delegate performSelector:@selector(touchOnMarker:) withObject:cell];
}


#pragma mark -
#pragma mark QB ActionStatusDelegate

-(void)completedWithResult:(Result *)result context:(void *)contextInfo
{
	if (result.success)
	{		
        // get more messages result
		if([((NSString *)contextInfo) isEqualToString:getMoreChatMessages])
		{
            QBLGeoDataPagedResult *geoDataSearchResult = (QBLGeoDataPagedResult *)result;
            
            // empty
            if([geoDataSearchResult.geodata count] == 0){
                // remove loading cell
                [((MapChatARViewController *)delegate).chatPoints removeLastObject];
                //
                NSIndexPath *newMessagePath = [NSIndexPath indexPathForRow:[((MapChatARViewController *)delegate).chatPoints count] inSection:0];
                NSArray *loadingCell = [[NSArray alloc] initWithObjects:newMessagePath, nil];
                //
                [messagesTableView deleteRowsAtIndexPaths:loadingCell withRowAnimation:UITableViewRowAnimationNone];
                
                isLoadingMoreMessages = NO;
                
                return;
            }
            
            
            
			// get fb users info
			NSMutableArray *fbChatUsersIds = [[NSMutableArray alloc] init];
			for (QBLGeoData *geodata in geoDataSearchResult.geodata){
				[fbChatUsersIds addObject:geodata.user.facebookID];
			}
			//
			NSMutableString* ids = [[NSMutableString alloc] init];
			for (NSString* userID in fbChatUsersIds)
			{
				[ids appendFormat:[NSString stringWithFormat:@"%@,", userID]];
			}
			
			if ([ids length] != 0)
			{
				NSString* q = [ids substringToIndex:[ids length]-1];
				[[FBService shared] usersProfilesWithIds:q delegate:self context:geoDataSearchResult.geodata];
			}
			[ids release];
			//
			[fbChatUsersIds release];
        }
	}
}

-(void)completedWithResult:(Result *)result{
    // Post new message result
    if(result.success){
        if([result isKindOfClass:QBLGeoDataResult.class]){
            QBLGeoDataResult *geoDataRes = (QBLGeoDataResult*)result; 
            
            // clear text
            messageField.text = @"";
            [messageField resignFirstResponder];
            
            // add new Annotation to map/chat/ar
            [((MapChatARViewController *)delegate) createAndAddNewAnnotationToMapChatARForFBUser:[DataManager shared].currentFBUser
                                                                            withGeoData:geoDataRes.geoData addToTop:YES withReloadTable:YES];
            
            [sendMessageActivityIndicator stopAnimating];
            messageField.rightView = nil;
            quotePhotoTop = nil;
            
            // scroll to top
            [messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
        // Send push result
        }else if([result isKindOfClass:QBMSendPushTaskResult.class]){
            NSLog(@"Send Push success");
        }

    }
}


#pragma mark -
#pragma mark FBServiceResultDelegate

- (void)completedWithFBResult:(FBServiceResult *)result context:(id)context
{
    // get FB Users profiles result 
    if (result.queryType == FBQueriesTypesUsersProfiles)
    {
        
        // remove loading cell
        [((MapChatARViewController *)delegate).chatPoints removeLastObject];


        // nem messages
        for (QBLGeoData *geodata in context) {
            
            NSDictionary *fbUser = nil;
            for(NSDictionary *user in [result.body allValues]){
                if([geodata.user.facebookID isEqualToString:[user objectForKey:kId]]){
                    fbUser = user;
                    break;
                }
            }
            
            // add point
            [((MapChatARViewController *)delegate) createAndAddNewAnnotationToMapChatARForFBUser:fbUser
                                                                            withGeoData:geodata addToTop:NO withReloadTable:NO];
        }
        
        // refresh table
        [self refresh];
    }
}


#pragma mark -
#pragma mark UIScrollViewDelegate

// Get More messages feature
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat thresholdToAction = [messagesTableView contentSize].height-300;
		
    if (([scrollView contentOffset].y >= thresholdToAction) && !isLoadingMoreMessages) {

		isLoadingMoreMessages = YES;
		
        // add load cell 
		UITableViewCell* cell = [[UITableViewCell alloc] init];
		UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, 7, 20, 20)];
		[loading setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
		[loading startAnimating];
		[cell.contentView addSubview:loading];
		[[(MapChatARViewController *)delegate chatPoints] addObject:cell];
		[loading release];
		//
		NSIndexPath *newMessagePath = [NSIndexPath indexPathForRow:[[(MapChatARViewController *)delegate chatPoints] indexOfObject:[[(MapChatARViewController *)delegate chatPoints] lastObject]] inSection:0];
		NSArray *newRows = [[NSArray alloc] initWithObjects:newMessagePath, nil];
		[messagesTableView insertRowsAtIndexPaths:newRows withRowAnimation:UITableViewRowAnimationNone];
		[newRows release];
		
        
        // get more messages
		[self getMoreMessages];
    }
}

@end
