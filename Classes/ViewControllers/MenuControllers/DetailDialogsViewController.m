//
//  DetailDialogsViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 29/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "DetailDialogsViewController.h"
#import "ChatRoomCell.h"
#import "FBService.h"
#import "FBStorage.h"
#import "QBService.h"
#import "LocationService.h"
#import "Utilites.h"

@interface DetailDialogsViewController ()

@end

@implementation DetailDialogsViewController
@synthesize quote;

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    self.chatHistory = [[NSMutableArray alloc]init];
	// Do any additional setup after loading the view.
    self.title = [NSString stringWithFormat:@"%@ %@", [self.myFriend objectForKey:kFirstName], [self.myFriend objectForKey:kLastName]];
    [self configureInputTextViewLayer];
    //[QBChat instance].delegate = self;
    //[QBUsers userWithFacebookID:[self.myFriend objectForKey:kId] delegate:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    [[FBService shared] inboxMessagesWithDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureInputTextViewLayer {
    self.inputTextView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.inputTextView.layer.shadowRadius = 7.0f;
    self.inputTextView.layer.masksToBounds = NO;
    self.inputTextView.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    self.inputTextView.layer.shadowOpacity = 1.0f;
    self.inputTextView.layer.borderWidth = 0.1f;
}


#pragma mark -
#pragma mark Actions

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendMessage:(id)sender {
    if ([self.inputMessageField.text isEqualToString: @""]) {
        NSLog(@"Empty message");
    } else {
        //send message to facebook:
        [[FBService shared] sendMessageToFacebook:self.inputMessageField.text withFriendFacebookID:[self.myFriend objectForKey:kId]];
        
        NSMutableDictionary *facebookMessage = [[NSMutableDictionary alloc] init];
        // put message to dictionary:
        [facebookMessage setValue:self.inputMessageField.text forKey:kMessage];
        
        NSDate *date = [NSDate date];
        [[Utilites shared].dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
        NSString *createdTime = [[Utilites shared].dateFormatter stringFromDate:date];
        [facebookMessage setValue:createdTime forKey:kCreatedTime];
        // back to default format mode
        [[Utilites shared].dateFormatter setDateFormat:@"HH:mm"];
        
        NSMutableDictionary *from = [[NSMutableDictionary alloc] init];
        [from setValue:[[FBStorage shared].currentFBUser objectForKey:kId] forKey:kId];
        [from setValue:[[FBStorage shared].currentFBUser objectForKey:kName] forKey:kName];
        [facebookMessage setValue:from forKey:kFrom];
        
        //message.text = jsonString;
        [self.chatHistory addObject:facebookMessage];
        self.inputMessageField.text = @"";
        [self.inputMessageField resignFirstResponder];
        [self reloadTableView];
    }
}

#pragma mark -
#pragma mark QBChatDelegate


- (void)chatDidReceiveMessage:(QBChatMessage *)message {
    [self.chatHistory addObject:message];
    [self reloadTableView];
}

- (void)reloadTableView {
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatHistory count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


//#pragma mark -
//#pragma mark QBActionStatusDelegate
//
//- (void)completedWithResult:(Result *)result {
//    if (result.success) {
//        if ([result isKindOfClass:[QBUUserResult class]]) {
//            QBUUserResult *userResult = (QBUUserResult *)result;
//            [QBService defaultService].qbFriend = userResult.user;
//        }
//    }
//}


#pragma mark -
#pragma mark Show/Hide Keyboard

-(void)showKeyboard{
    CGRect tableViewFrame = self.tableView.frame;
    CGRect inputPanelFrame = _inputTextView.frame;
    tableViewFrame.origin.y -= 215;
    inputPanelFrame.origin.y -= 215;
    //animation
    [UIView animateWithDuration:0.25f animations:^{
        [self.tableView setFrame:tableViewFrame];
        [_inputTextView setFrame:inputPanelFrame];
    }];
}

-(void)hideKeyboard{
    CGRect tableViewFrame = self.tableView.frame;
    CGRect inputPanelFrame = _inputTextView.frame;
    tableViewFrame.origin.y += 215;
    inputPanelFrame.origin.y += 215;
    //animation
    [UIView animateWithDuration:0.25f animations:^{
        [self.tableView setFrame:tableViewFrame];
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
#pragma mark Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.chatHistory == nil) ? 1 :[self.chatHistory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *roomCellIdentifier = @"RoomCellIdentifier";
    NSDictionary *message = [_chatHistory objectAtIndex:indexPath.row];
       UITableViewCell *cell = (ChatRoomCell *)[tableView dequeueReusableCellWithIdentifier:roomCellIdentifier];
        if (cell == nil){
            cell = [[ChatRoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:roomCellIdentifier];
        }
        [(ChatRoomCell *)cell handleParametersForCellWithFBMessage:message andIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *chatString = [[_chatHistory objectAtIndex:indexPath.row] objectForKey:kMessage];
    return [ChatRoomCell configureHeightForCellWithMessage:chatString];
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark FBServiceResultDelegate

- (void)completedWithFBResult:(FBServiceResult *)result {
    
    // get inbox messages
    if (result.queryType == FBQueriesTypesGetInboxMessages){
        
        NSArray *resultData = [result.body objectForKey:kData];
        //NSDictionary *resultError = [result.body objectForKey:kError];
  
        // each inbox message
		for(NSDictionary *inboxConversation in resultData)
		{
            NSArray *dialogTo = [[inboxConversation objectForKey:kTo] objectForKey:kData];
            for (NSDictionary *user in dialogTo) {
                if ([[user objectForKey:kId] isEqual:[self.myFriend objectForKey:kId]]) {
                    NSMutableArray *conversation = [[inboxConversation objectForKey:kComments] objectForKey:kData];
                    [[FBStorage shared] setHistoryConversation:conversation];
                    self.chatHistory = conversation;
                    [self reloadTableView];
                }
            }
        }
    }
}

@end
