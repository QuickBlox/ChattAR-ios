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
#import "ChatRoomsService.h"
#import "QuotedChatRoomCell.h"
#import "FBStorage.h"
#import "FBService.h"
#import "QBService.h"
#import "LocationService.h"
#import <CoreLocation/CoreLocation.h>


@interface ChatRoomViewController ()

@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) NSMutableDictionary *quote;
@property (strong, nonatomic) QBChatRoom *currentRoom;
@property (strong, nonatomic) QBChatMessage *userMessage;
@property (strong, nonatomic) IBOutlet UIView *inputTextView;
@property (strong, nonatomic) IBOutlet UITextField *inputMessageField;
@property (strong, nonatomic) NSMutableArray *chatHistory;
@property (strong, nonatomic) NSIndexPath *cellPath;
@property CGFloat cellSize;

-(IBAction)textEditDone:(id)sender;
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
    self.title = @"Default";
    [self setPin];
    self.chatHistory = [[NSMutableArray alloc] init];
    self.inputTextView.layer.shadowColor = [[UIColor blackColor] CGColor];
    [self configureInputTextViewLayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sayHelloy) name:@"activatechat" object:nil];
}
-(void)sayHelloy{
    NSLog(@"Helloy!!!");
}

-(void)setPin{
    if (!self.indicatorView) {
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicatorView.frame = CGRectMake(self.chatRoomTable.frame.size.width/2 - 10, self.chatRoomTable.frame.size.height/2 -10, 20 , 20);
        [self.indicatorView hidesWhenStopped];
        [self.chatRoomTable addSubview:self.indicatorView];
    }
    [self.indicatorView startAnimating];
}

- (void)configureInputTextViewLayer{
    self.inputTextView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.inputTextView.layer.shadowRadius = 7.0f;
    self.inputTextView.layer.masksToBounds = NO;
    self.inputTextView.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    self.inputTextView.layer.shadowOpacity = 1.0f;
    self.inputTextView.layer.borderWidth = 0.1f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setChatRoomTable:nil];
    [self setBackButton:nil];
    [self setInputTextView:nil];
    [self setInputMessageField:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated{
    NSString *roomName = [_currentChatRoom.fields objectForKey:kName];
    self.title = roomName;
    [self creatingOrJoiningRoom];
    [_chatRoomTable reloadData];
    [super viewWillAppear:animated];
}


#pragma mark -
#pragma mark Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_chatHistory count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
        [(ChatRoomCell *)cell handleParametersForCellWithMessage:qbMessage andIndexPath:indexPath];
    } else {
        cell = (QuotedChatRoomCell *)[tableView dequeueReusableCellWithIdentifier:quotedRoomCellIdentifier];
        if (cell == nil) {
            cell = [[QuotedChatRoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:quotedRoomCellIdentifier];
        }
        [(QuotedChatRoomCell *)cell handleParametersForCellWithMessage:qbMessage andIndexPath:indexPath];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat cellHeight;
    NSString *chatString = [[_chatHistory objectAtIndex:indexPath.row] text];
    NSData *data = [chatString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *currentMessage = [dictionary objectForKey:kMessage];
    if ([dictionary objectForKey:kQuote] == nil) {
       cellHeight = [ChatRoomCell configureHeightForCellWithDictionary:currentMessage];
    } else {
        cellHeight = [QuotedChatRoomCell configureHeightForCellWithDictionary:currentMessage];
    }
    return cellHeight;
}


#pragma mark -
#pragma mark Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.chatRoomTable deselectRowAtIndexPath:indexPath animated:YES];
    QBChatMessage *chatMsg = [_chatHistory objectAtIndex:[indexPath row]];
    if (![chatMsg.senderNick isEqual:[[FBStorage shared].currentFBUser objectForKey:kId]]) {
        cellPath = indexPath;
        NSString *title = [[NSString alloc] initWithFormat:@"What do you want?"];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", nil];
    [actionSheet showInView:self.view];
    }
}


#pragma mark -
#pragma mark UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"Button whith number %i was clicked", buttonIndex);
    switch (buttonIndex) {
        case 0:
            // do something
            NSLog(@"REPLY");
            QBChatMessage *msg = [_chatHistory objectAtIndex:[cellPath row]];
            
            NSString *string = msg.text;
            cellPath = nil;
            // JSON parsing
            NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            //saving user...
            if (quote == nil) {
                quote = [[NSMutableDictionary alloc] init];
            }
        
            NSString *time = [[Utilites shared].dateFormatter stringFromDate:msg.datetime];
            
            [quote setValue:[jsonDict objectForKey:kUserPhotoUrl] forKey:kUserPhotoUrl];
            [quote setValue:[jsonDict objectForKey:kUserName] forKey:kUserName];
            [quote setValue:[jsonDict objectForKey:kMessage] forKey:kMessage];
            [quote setValue:time forKey:kDateTime];
            
            [self.inputMessageField becomeFirstResponder];
            break;
    }
}

#pragma mark -
#pragma mark ChatRoom

-(void)creatingOrJoiningRoom{
    // Join room
    [QBChat instance].delegate = self;
    NSString *roomName = [_currentChatRoom.fields objectForKey:kName];
    [[QBChat instance] createOrJoinRoomWithName:roomName nickname:[[FBStorage shared].currentFBUser objectForKey:kId] membersOnly:NO persistent:YES];
}


#pragma mark -
#pragma mark QBChatDelegate

-(void)chatDidLogin{
    // if room entered
    if ([[FBService shared] fbChatRoomDidEnter] == YES) {
        [self creatingOrJoiningRoom];
    }
}

// if chat room is created or user is joined
-(void)chatRoomDidEnter:(QBChatRoom *)room{
    [room addUsers:@[@34]];
    NSLog(@"Chat Room is opened");
    [[FBService shared] setFbChatRoomDidEnter:YES];
    [[QBService defaultService] setCurrentChatRoom:room];
    //get room
    self.currentRoom = room;
    
//    // Update chat room rank
//    NSNumber *rank = [_currentChatRoom.fields objectForKey:@"rank"];
//    NSUInteger intRank = [rank intValue];
//    intRank+=1;
//    [_currentChatRoom.fields setValue:[NSNumber numberWithInt:intRank] forKey:@"rank"];
//    [QBCustomObjects updateObject:_currentChatRoom delegate:nil];
    [self.indicatorView stopAnimating];
}

- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error{
    NSLog(@"Error:%@", error);
}

// back button
- (IBAction)backToRooms:(id)sender {
    [[FBService shared] setFbChatRoomDidEnter:NO];
    [[QBChat instance] leaveRoom:[[QBService defaultService] currentChatRoom]];
    //_currentRoom = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)chatRoomDidLeave:(NSString *)roomName{
    NSLog(@"Did  Leave worked");
    [QBService defaultService].currentChatRoom = nil;
}

// action message button
- (IBAction)sendMessageButton:(id)sender {
    if ([self.inputMessageField.text isEqual:@""]) {
        //don't send
    } else {
        NSString *myLatitude = [[NSString alloc] initWithFormat:@"%f",[[LocationService shared] getMyCoorinates].latitude];
        NSString *myLongitude = [[NSString alloc] initWithFormat:@"%f", [[LocationService shared] getMyCoorinates].longitude];
        NSString *userName =  [NSString stringWithFormat:@"%@ %@",[[FBStorage shared].currentFBUser objectForKey:kFirstName], [[FBStorage shared].currentFBUser objectForKey:kLastName]];
        
        NSString *urlString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", [[FBStorage shared].currentFBUser objectForKey:kId], [FBStorage shared].accessToken];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:myLatitude forKey:kLatitude];
        [dict setValue:myLongitude forKey:kLongitude];
        [dict setValue:urlString forKey:kUserPhotoUrl];
        [dict setValue:userName forKey:kUserName];
        if (quote != nil) {
            [dict setValue:quote forKey:kQuote];
            quote = nil;
        }
        [dict setValue:self.inputMessageField.text forKey:kMessage];
        // formatting to JSON:
        NSError *error = nil;
        NSData* nsdata = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString* jsonString =[[NSString alloc] initWithData:nsdata encoding:NSUTF8StringEncoding];
        
        [[QBChat instance] sendMessage:jsonString toRoom:self.currentRoom];
        self.inputMessageField.text = @"";
    }
    [self.chatRoomTable reloadData];
    [self.inputMessageField resignFirstResponder];
}

//  receiving messages
-(void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoom:(NSString *)roomName{
    QBDLogEx(@"message %@", message);
    
    self.userMessage = message;
    [self.chatHistory addObject:message];
    [self.chatRoomTable reloadData];
    [self.chatRoomTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_chatHistory count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}
#pragma mark -
#pragma mark Show/Hide Keyboard

-(void)showKeyboard{
    CGRect tableViewFrame = self.chatRoomTable.frame;
    CGRect inputPanelFrame = _inputTextView.frame;
    tableViewFrame.origin.y -= 215;
    inputPanelFrame.origin.y -= 215;
    //animation
    [UIView animateWithDuration:0.25f animations:^{
        [self.chatRoomTable setFrame:tableViewFrame];
        [_inputTextView setFrame:inputPanelFrame];
    }];
}

-(void)hideKeyboard{
    CGRect tableViewFrame = self.chatRoomTable.frame;
    CGRect inputPanelFrame = _inputTextView.frame;
    tableViewFrame.origin.y += 215;
    inputPanelFrame.origin.y += 215;
    //animation
    [UIView animateWithDuration:0.25f animations:^{
        [self.chatRoomTable setFrame:tableViewFrame];
        [_inputTextView setFrame:inputPanelFrame];
    }];    
}

#pragma mark -
#pragma mark UITextField

-(IBAction)textEditDone:(id)sender{
    [sender resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self showKeyboard];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self hideKeyboard];
}


#pragma mark -
#pragma mark Sharing

- (IBAction)share:(id)sender {
    UIActivityViewController *shareKit = [[UIActivityViewController alloc] initWithActivityItems:@[@"I use ChattAR 2.0"] applicationActivities:nil];
    [self presentViewController:shareKit animated:YES completion:nil];
}

@end
