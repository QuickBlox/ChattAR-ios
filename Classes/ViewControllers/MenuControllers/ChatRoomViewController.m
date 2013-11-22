//
//  ChatRoomViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 11/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//
#import "ChatViewController.h"
#import "ChatRoomViewController.h"
#import "ChatRoomCell.h"
#import "ChatRoomStorage.h"
#import "QuotedChatRoomCell.h"
#import "FBStorage.h"
#import "FBService.h"
#import "QBService.h"
#import "QBStorage.h"
#import "DetailDialogsViewController.h"
#import "ProfileViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <Social/Social.h>



@interface ChatRoomViewController ()

@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) NSMutableDictionary *quote;
@property (strong, nonatomic) QBChatRoom *currentRoom;
@property (strong, nonatomic) IBOutlet UIView *inputTextView;
@property (strong, nonatomic) IBOutlet UITextField *inputMessageField;
@property (strong, nonatomic) NSMutableArray *chatHistory;
@property (strong, nonatomic) NSIndexPath *cellPath;
@property (strong, nonatomic) NSMutableDictionary *dialogTo;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinedRoom) name:CAChatRoomDidEnterNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived) name:CAChatRoomDidReceiveOrSendMessageNotification object:nil];
    [self setSpinner];
    [self configureInputTextViewLayer];
    NSString *roomName = [_currentChatRoom.fields objectForKey:kName];
    self.title = roomName;
    [self creatingOrJoiningRoom];
}

- (void)setSpinner
{
    if (!self.indicatorView) {
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicatorView.frame = CGRectMake(self.chatRoomTable.frame.size.width/2 - 10, self.chatRoomTable.frame.size.height/2 -10, 20 , 20);
        [self.indicatorView hidesWhenStopped];
        [self.chatRoomTable addSubview:self.indicatorView];
    }
    [self.indicatorView startAnimating];
}

- (void)configureInputTextViewLayer
{
    self.inputTextView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.inputTextView.layer.shadowRadius = 7.0f;
    self.inputTextView.layer.masksToBounds = NO;
    self.inputTextView.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    self.inputTextView.layer.shadowOpacity = 1.0f;
    self.inputTextView.layer.borderWidth = 0.1f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_chatRoomTable reloadData];
}


#pragma mark -
#pragma mark Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_chatHistory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *roomCellIdentifier = @"RoomCellIdentifier";
    static NSString *quotedRoomCellIdentifier = @"quotedRoomCellIdentifier";
    
    QBChatMessage *qbMessage = [_chatHistory objectAtIndex:[indexPath row]];
    NSString *string = [NSString stringWithFormat:@"%@", qbMessage.text];
    // JSON parsing
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    // There are Two different cells: "Simple" and "Quoted"
    if ([jsonDict objectForKey:kQuote] == nil) {
        cell = (ChatRoomCell *)[tableView dequeueReusableCellWithIdentifier:roomCellIdentifier];
        if (cell == nil){
            cell = [[ChatRoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:roomCellIdentifier];
        }
        [(ChatRoomCell *)cell handleParametersForCellWithQBMessage:qbMessage andIndexPath:indexPath];
    } else {
        cell = (QuotedChatRoomCell *)[tableView dequeueReusableCellWithIdentifier:quotedRoomCellIdentifier];
        if (cell == nil) {
            cell = [[QuotedChatRoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:quotedRoomCellIdentifier];
        }
        [(QuotedChatRoomCell *)cell handleParametersForCellWithMessage:qbMessage andIndexPath:indexPath];
    }
    return cell;
}

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


#pragma mark -
#pragma mark Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.chatRoomTable deselectRowAtIndexPath:indexPath animated:YES];
    QBChatMessage *chatMsg = [_chatHistory objectAtIndex:[indexPath row]];
    NSMutableDictionary *messageData = [[QBService defaultService] unarchiveMessageData:chatMsg.text];
    NSString *userID = [messageData objectForKey:kId];
    if (![userID isEqual:[[FBStorage shared].me objectForKey:kId]]) {
        cellPath = indexPath;
        NSString *title = [[NSString alloc] initWithFormat:@"What do you want?"];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", @"Go to dialog", @"View Profile", nil];
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
            cellPath = nil;
            // JSON parsing
            NSDictionary *jsonDict = [[QBService defaultService] unarchiveMessageData:string];
            
            //saving user...
            if (quote == nil) {
                quote = [[NSMutableDictionary alloc] init];
            }
            NSString *time = [[Utilites shared].dateFormatter stringFromDate:msg.datetime];
            
            [quote setValue:[jsonDict objectForKey:kPhoto] forKey:kPhoto];
            [quote setValue:[jsonDict objectForKey:kUserName] forKey:kUserName];
            [quote setValue:[jsonDict objectForKey:kMessage] forKey:kMessage];
            [quote setValue:time forKey:kDateTime];
            
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

- (NSMutableDictionary *)userWithMessage:(QBChatMessage *)message {
    NSMutableDictionary *currentFriend = [[FBStorage shared] findUserWithMessage:message];
    if (currentFriend == nil) {
        //creating FBUser(No Friend):
        NSMutableDictionary *messageData = [[QBService defaultService] unarchiveMessageData:message.text];
        currentFriend = [[NSMutableDictionary alloc] init];
        [currentFriend setObject:[messageData objectForKey:kUserName] forKey:kName];
        NSString *urlString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", [messageData objectForKey:kId], [FBStorage shared].accessToken];
        [currentFriend setObject:urlString forKey:kPhoto];
        [currentFriend setObject:[messageData objectForKey:kId] forKey:kId];
        [currentFriend setObject:[messageData objectForKey:kQuickbloxID] forKey:kQuickbloxID];
        // caching created user:
        [[QBStorage shared].otherUsers addObject:currentFriend];
    }
    return currentFriend;
}


#pragma mark -
#pragma mark ChatRoom

- (void)creatingOrJoiningRoom
{
    NSString *facebookID = [[FBStorage shared].me objectForKey:kId];
    NSString *roomName = [_currentChatRoom.fields objectForKey:kName];
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
    [QBStorage shared].currentChatRoom = nil;
    [QBService defaultService].userIsJoinedChatRoom = NO;
    [[QBStorage shared].chatHistory removeAllObjects];
    [self.navigationController popViewControllerAnimated:YES];
}

// action message button
- (IBAction)sendMessageButton:(id)sender
{
    if ([self.inputMessageField.text isEqual:@""]) {
        //don't send
        [self.inputMessageField resignFirstResponder];
        return;
    }
        [[QBService defaultService] sendmessage:self.inputMessageField.text toChatRoom:self.currentRoom quote:quote];
        self.inputMessageField.text = @"";
    [self.chatRoomTable reloadData];
    [self.inputMessageField resignFirstResponder];
}


#pragma mark -
#pragma mark Notifications

- (void)resetTableView {
    [self.chatRoomTable reloadData];
    [self.chatRoomTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_chatHistory count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)joinedRoom {
    self.currentRoom = [QBStorage shared].currentChatRoom;
    [self.chatRoomTable reloadData];
    [self.indicatorView stopAnimating];
}

- (void)messageReceived {
    self.chatHistory = [QBStorage shared].chatHistory;
    [self resetTableView];
}

#pragma mark -
#pragma mark Show/Hide Keyboard

- (void)showKeyboard
{
    [UIView animateWithDuration:0.275 animations:^{
        self.inputTextView.transform = CGAffineTransformMakeTranslation(0, -215);
        self.chatRoomTable.transform = CGAffineTransformMakeTranslation(0, -215);
    }];
}

- (void)hideKeyboard
{
    [UIView animateWithDuration:0.275 animations:^{
        self.inputTextView.transform = CGAffineTransformIdentity;
        self.chatRoomTable.transform = CGAffineTransformIdentity;;
    }];
}


#pragma mark -
#pragma mark UITextField

- (IBAction)textEditDone:(id)sender
{
    [sender resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self showKeyboard];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self hideKeyboard];
}


#pragma mark -
#pragma mark Sharing

- (IBAction)share:(id)sender
{
    NSString *initialText = [NSString stringWithFormat:@"Hi! I use ChattAR app - Chat in Augmented Reality. Join me in a cool chat room \"%@\"!  #chattar #facebook", [_currentChatRoom.fields objectForKey:kName]];
    
    SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [composeController setInitialText:initialText];
    [self presentViewController:composeController animated:YES completion:nil];
    [composeController setCompletionHandler:^(SLComposeViewControllerResult result) {
        
        switch (result) {
            case SLComposeViewControllerResultCancelled:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cancelled"
                                                          message:@"Something was wrong. Please, try again."
                                                          delegate:nil
                                                      cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
                break;
            case SLComposeViewControllerResultDone:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done!"
                                                                message:@"Message successfuly posted."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
                break;
                
            default:
                break;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];;
}


#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kChatToProfileSegieIdentifier]) {
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

@end
