//
//  ChatRoomViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 11/09/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "ChatRoomViewController.h"
#import "ChatRoomCell.h"
#import "ChatRoomStorage.h"
#import "QuotedChatRoomCell.h"
#import "AsyncImageView.h"
#import "FBStorage.h"
#import "FBService.h"
#import "QBService.h"
#import "QBStorage.h"
#import "DetailDialogsViewController.h"
#import "ProfileViewController.h"
#import "ChatRoomDataSource.h"
#import "Utilites.h"
#import "MBProgressHUD.h"

#import "NSString+Parsing.h"


@interface ChatRoomViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, QBChatDelegate, QBActionStatusDelegate, CLLocationManagerDelegate, UIActionSheetDelegate, SASlideMenuDelegate>

@property (strong, nonatomic) ChatRoomDataSource *chatRoomDataSource;
@property (nonatomic, copy)   NSString *opponentID;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) NSMutableDictionary *quote;
@property (strong, nonatomic) IBOutlet UIView *inputTextView;
@property (strong, nonatomic) IBOutlet UITextField *inputMessageField;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) NSMutableArray *chatHistory;
@property (strong, nonatomic) NSIndexPath *cellPath;
@property (strong, nonatomic) NSMutableDictionary *dialogTo;

@property (strong, nonatomic) UIWindow *currentWindow;

@property CGFloat cellSize;

- (IBAction)textEditDone:(id)sender;
- (IBAction)backToRooms:(id)sender;
- (IBAction)sendMessageButton:(id)sender;

@end

@implementation ChatRoomViewController
@synthesize cellPath;
@synthesize quote;


#pragma mark LifeCycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.chatRoomDataSource = [[ChatRoomDataSource alloc] init];
    self.chatRoomTable.dataSource = self.chatRoomDataSource;
    self.chatRoomDataSource.chatHistory = self.chatHistory;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinedRoom) name:CAChatRoomDidEnterNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived) name:CAChatRoomDidReceiveOrSendMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordPublished:) name:CARoomDidPublishedToFacebookNotification object:nil];
    // KEYBOARD NOTIFICATIONS
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard) name:UIKeyboardWillHideNotification object:nil];
    
    self.currentWindow = [[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD *currentHUD = [MBProgressHUD HUDForView:self.currentWindow];
    if (currentHUD == nil) {
        [Utilites shared].progressHUD = [MBProgressHUD showHUDAddedTo:self.currentWindow animated:YES];
        [[Utilites shared].progressHUD setLabelText:@"Joining room..."];
    } else {
        [currentHUD setLabelText:@"Joining room..."];
        [currentHUD performSelector:@selector(show:) withObject:nil];
    }
 
    [self configureInputTextViewLayer];
    NSString *roomName = [_currentChatRoom.fields objectForKey:kName];
    self.title = roomName;
    [self creatingOrJoiningRoom];
}

- (void)configureInputTextViewLayer
{
    self.inputTextView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.inputTextView.layer.shadowRadius = 7.0f;
    self.inputTextView.layer.masksToBounds = NO;
    self.inputTextView.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    self.inputTextView.layer.shadowOpacity = 1.0f;
    self.inputTextView.layer.borderWidth = 0.1f;
    
    // button corner-radius
    self.sendButton.layer.cornerRadius = 5.0f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [ControllerStateService shared].isInChatRoom = YES;
    [self.chatRoomTable reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:NO];
    [ControllerStateService shared].isInChatRoom = NO;
}


#pragma mark -
#pragma mark Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Identifier"];
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight;
    NSString *chatString = [[_chatHistory objectAtIndex:indexPath.row] text];
    NSData *data = [chatString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *currentMessage = [dictionary objectForKey:kMessage];
    if ([dictionary objectForKey:kQuote] == nil) {
       cellHeight = [ChatRoomCell configureHeightForCellWithMessage:currentMessage];
    } else {
        cellHeight = [QuotedChatRoomCell configureHeightForCellWithDictionary:currentMessage];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.chatRoomTable deselectRowAtIndexPath:indexPath animated:YES];
    QBChatMessage *chatMsg = [_chatHistory objectAtIndex:[indexPath row]];
    NSMutableDictionary *messageData = [[QBService defaultService] unarchiveMessageData:chatMsg.text];
    if (messageData[@"mr_quick"] != nil) {
        return;
    }
    NSString *userID = [messageData objectForKey:kId];
    if (![userID isEqual:[[FBStorage shared].me objectForKey:kId]]) {
        cellPath = indexPath;
        NSString *title = messageData[kUserName];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", @"Private message", @"View Profile", nil];
        [actionSheet showInView:self.view];
    }
}


#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"REPLY");
            QBChatMessage *msg = [_chatHistory objectAtIndex:[cellPath row]];
            
            NSString *string = msg.text;
            // JSON parsing
            NSDictionary *jsonDict = [[QBService defaultService] unarchiveMessageData:string];
            
            //saving user...
            if (quote == nil) {
                quote = [[NSMutableDictionary alloc] init];
            }
            self.opponentID = jsonDict[kQuickbloxID];
            NSString *time = [[Utilites shared].dateFormatter stringFromDate:msg.datetime];
            
            quote[kPhoto] = jsonDict[kPhoto];
            quote[kUserName] = jsonDict[kUserName];
            quote[kMessage] =jsonDict[kMessage];
            quote[kDateTime] = time;
            
            // user's replay image
            AsyncImageView *imgView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            [imgView setImageURL:[NSURL URLWithString:jsonDict[kPhoto]]];
            self.inputMessageField.rightView = imgView;
            self.inputMessageField.rightViewMode = UITextFieldViewModeWhileEditing;
            [self.inputMessageField becomeFirstResponder];
            
            break;
        }
        case 1:
        {
            // Dialogs View Controller:
            QBChatMessage *msg = [_chatHistory objectAtIndex:[cellPath row]];
            NSMutableDictionary *currentUser = [self userWithMessage:msg];
            if ([[FBStorage shared] isFacebookFriend:currentUser]) {
                NSMutableDictionary *dialog = [FBService findFBConversationWithFriend:currentUser];
                self.dialogTo = dialog;
            } else {
                // finding QB conversation:
                NSMutableDictionary *dialog = [[QBService defaultService] findConversationToUserWithMessage:msg];
                    self.dialogTo = dialog;
            }
            [self performSegueWithIdentifier:kChatToDialogSegueIdentifier sender:currentUser];
            break;
        }
        case 2:
        {
            // Profile View Controller:
            QBChatMessage *msg = [_chatHistory objectAtIndex:[cellPath row]];
            NSMutableDictionary *currentFriend = [self userWithMessage:msg];
            [self performSegueWithIdentifier:kChatToProfileSegieIdentifier sender:currentFriend];
            break;
        }
    }
}

- (NSMutableDictionary *)userWithMessage:(QBChatMessage *)message
{
    NSMutableDictionary *currentFriend = [[FBStorage shared] findUserWithMessage:message];
    if (currentFriend == nil) {
        //creating FBUser(No Friend):
        NSMutableDictionary *messageData = [[QBService defaultService] unarchiveMessageData:message.text];
        currentFriend = [[NSMutableDictionary alloc] init];

        NSString *fullName = messageData[kUserName];
        currentFriend[kName] = fullName;
        NSString *firstName = [fullName firstNameFromNameField];
        currentFriend[kFirstName] = firstName;
        NSString *lastName = [fullName lastNameFromNameField];
        currentFriend[kLastName] = lastName;
        
        NSString *urlString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", messageData[kId], [FBStorage shared].accessToken];
        currentFriend[kPhoto] = urlString;
        currentFriend[kId] = messageData[kId];
        currentFriend[kQuickbloxID] = messageData[kQuickbloxID];
        // caching created user:
        [[QBStorage shared].otherUsers addObject:currentFriend];
        [QBStorage shared].otherUsersAsDictionary[messageData[kId]] = currentFriend;
    }
    return currentFriend;
}


//#pragma mark -
//#pragma mark MBProgressHUD Delegate
//
//- (void)hudWasHidden:(MBProgressHUD *)hud
//{
//    
//}


#pragma mark -
#pragma mark ChatRoom

- (void)creatingOrJoiningRoom
{
    NSString *facebookID = [FBStorage shared].me[kId];
    NSString *roomName = _currentChatRoom.fields[kName];
    // saving room name to cache:
    [QBStorage shared].chatRoomName = roomName;
    // login to room:
    [[QBService defaultService] chatCreateOrJoinRoomWithName:roomName andNickName:facebookID];
}


#pragma mark -
#pragma mark Actions

// back button
- (IBAction)backToRooms:(id)sender
{
    [QBStorage shared].joinedChatRoom = nil;
    [QBService defaultService].userIsJoinedChatRoom = NO;
    
    [[QBStorage shared].chatHistory removeAllObjects];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// action message button
- (IBAction)sendMessageButton:(id)sender
{
    // trim chat message
    NSString *trimmedString = [self.inputMessageField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // don't send if empty message
    if (trimmedString.length == 0) {
        [self.inputMessageField resignFirstResponder];
        return;
    }
    // Send message to chat room
    [[QBService defaultService] sendMessage:trimmedString toChatRoom:[QBStorage shared].joinedChatRoom quote:quote];
    if (quote != nil) {
        NSString *roomName = self.currentChatRoom.fields[kName];
        NSString *pushMessage = [NSString stringWithFormat:@"Your message in chat room %@ was quoted by %@", roomName, [FBStorage shared].me[kName]];
        [[QBService defaultService] sendPushNotificationWithMessage:pushMessage toUser:self.opponentID roomName:roomName];
    }
    self.inputMessageField.text = @"";
    [self.chatRoomTable reloadData];
    [self.inputMessageField resignFirstResponder];
}


#pragma mark -
#pragma mark Notifications

- (void)resetTableView
{
    [self.chatRoomTable reloadData];
    if ([_chatHistory count] > 2) {
        [self.chatRoomTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_chatHistory count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)joinedRoom
{
    [Flurry logEvent:kFlurryEventRoomWasJoined withParameters:@{kFrom:self.controllerName}];
    
    [[ChatRoomStorage shared] increaseRankOfRoom:self.currentChatRoom];
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:3.0];
    [self.chatRoomTable reloadData];
}

- (void)hideHUD
{
    [[Utilites shared].progressHUD performSelector:@selector(hide:) withObject:nil];
    if (_chatHistory == nil) {
        _chatHistory = [[NSMutableArray alloc] init];
        self.chatRoomDataSource.chatHistory = _chatHistory;
        // Wellcome message from Mr. Quick!
        [self firstMessageFromMrQuick];
        [self.chatRoomTable reloadData];
    }
}

- (void)firstMessageFromMrQuick {
    QBChatMessage *quickMsg = [QBChatMessage message];
    quickMsg.ID = @"1";
    
    NSDate *date = [NSDate date];
    quickMsg.datetime = date;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[kUserName] = @"Mr. Quick";
    dict[kMessage] = [NSString stringWithFormat:@"Hey %@! Fill free to start conversation here and share chat room to your friends!", [FBStorage shared].me[kFirstName]];
    dict[kPhoto] = [ChatRoomCell imageForMrQuick];
    dict[@"mr_quick"] = @"mr_quick";
    NSString *jsonString = [[QBService defaultService] archiveMessageData:dict];
    
    quickMsg.text = jsonString;
    [_chatHistory addObject:quickMsg];
}

- (void)messageReceived
{
    self.chatHistory = [QBStorage shared].chatHistory;
    self.chatRoomDataSource.chatHistory = self.chatHistory;
    [self resetTableView];
    
    MBProgressHUD *currentHUD = [Utilites shared].progressHUD;
    [NSObject cancelPreviousPerformRequestsWithTarget:currentHUD selector:@selector(hide:) object:nil];
    [currentHUD performSelector:@selector(hide:) withObject:nil afterDelay:2.0];
}

- (void)recordPublished:(NSNotification *)aNotification
{
    [Utilites shared].isShared = NO;
    [[Utilites shared].progressHUD performSelector:@selector(hide:) withObject:nil afterDelay:2.0];
    NSError *error = aNotification.object;
    NSString *alertText;
    if (error) {
        alertText = [NSString stringWithFormat:
                     @"error: domain = %@, code = %d",
                     error.domain, error.code];
    } else {
        alertText = [NSString stringWithFormat:
                     @"Message was posted successfully"];
        [Flurry logEvent:kFlurryEventRoomWasSharedToFacebook];
    }
    // Show the result in an alert
    [[[UIAlertView alloc] initWithTitle:@"Result"
                                message:alertText
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil]
     show];
}


#pragma mark -
#pragma mark Show/Hide Keyboard

- (void)showKeyboard
{
    CGRect tableFrame = self.chatRoomTable.frame;
    tableFrame.size.height -= 215;
    
    
    [UIView animateWithDuration:0.250 animations:^{
        self.inputTextView.transform = CGAffineTransformMakeTranslation(0, -215);
        self.chatRoomTable.frame = tableFrame;
        if ([_chatHistory count] < 2) {
            return;
        }
        if (cellPath != nil) {
            [self.chatRoomTable scrollToRowAtIndexPath:cellPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            cellPath = nil;
            return;
        }
        [self.chatRoomTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_chatHistory count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }];
}


- (void)hideKeyboard
{
    // if quote is cancelled:
    quote = nil;
    self.inputMessageField.rightView = nil;
    
    CGRect tableFrame = self.chatRoomTable.frame;
    tableFrame.size.height += 215;
    
    [UIView animateWithDuration:0.250 animations:^{
        self.inputTextView.transform = CGAffineTransformIdentity;
        self.chatRoomTable.frame = tableFrame;
    }];
}


#pragma mark -
#pragma mark UITextField

- (IBAction)textEditDone:(id)sender
{
    [sender resignFirstResponder];
}


#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kChatToProfileSegieIdentifier]) {
        ((ProfileViewController *)segue.destinationViewController).controllerTitle = @"room";   // info for Flurry analytics
        ((ProfileViewController *)segue.destinationViewController).currentUser = sender;
        return;
    }
    ((DetailDialogsViewController *)segue.destinationViewController).opponent = sender;
    ((DetailDialogsViewController *)segue.destinationViewController).conversation = self.dialogTo;
    if ([[FBStorage shared] isFacebookFriend:sender]) {
        ((DetailDialogsViewController *)segue.destinationViewController).isChatWithFacebookFriend = YES;
        return;
    }
    ((DetailDialogsViewController *)segue.destinationViewController).isChatWithFacebookFriend = NO;
}


#pragma mark -
#pragma mark Sharing

- (IBAction)share:(id)sender
{
    [Utilites shared].isShared = YES;
    [Utilites shared].progressHUD = [MBProgressHUD showHUDAddedTo:self.currentWindow animated:YES];
    [[Utilites shared].progressHUD setLabelText:@"Sharing..."];
    NSString *initialText = [NSString stringWithFormat:@"Hi! I'm using #chattar - Chat in Augmented Reality. Join me in a %@ room to start augmented reality chat! #facebook #quickblox", [_currentChatRoom.fields objectForKey:kName]];
    
    // Ask for publish_actions permissions in context
    if ([FBSession.activeSession.permissions
         indexOfObject:@"publish_actions"] == NSNotFound) {
        // No permissions found in session, ask for it
        [FBSession.activeSession
         requestNewPublishPermissions:@[@"publish_actions"]
         defaultAudience:FBSessionDefaultAudienceFriends
         completionHandler:^(FBSession *session, NSError *error) {
             if (!error) {
                 // If permissions granted, publish the story
                 [[FBService shared] publishMessageToFeed:initialText];
             }
         }];
    } else {
        // If permissions present, publish the story
        [[FBService shared] publishMessageToFeed:initialText];
    }
}

@end
