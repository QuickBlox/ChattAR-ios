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
#import "FBChatService.h"
#import "QBService.h"
#import "LocationService.h"
#import "Utilites.h"

@interface DetailDialogsViewController ()

@end

@implementation DetailDialogsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.conversation == nil) {
        self.conversation = [[NSMutableDictionary alloc]init];
    }
	// Do any additional setup after loading the view.
    self.title = [self.myFriend objectForKey:kName];
    [self configureInputTextViewLayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage) name:kNotificationMessageReceived object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    [self reloadTableView];
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
    [[FBChatService defaultService].allFriendsHistoryConversation setObject:self.conversation forKey:kComments];
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
        
        
        [[[self.conversation objectForKey:kComments] objectForKey:kData] addObject:facebookMessage];
        self.inputMessageField.text = @"";
        [self.inputMessageField resignFirstResponder];
        
        if (([[self.conversation objectForKey:kComments] objectForKey:kData] == nil) || [[[self.conversation objectForKey:kComments] objectForKey:kData] count] == 0) {
            [[FBService shared] sendMessageToFacebook:self.inputMessageField.text withFriendFacebookID:[self.myFriend objectForKey:kId]];
        }
        
        [self reloadTableView];
    }
}

- (void)receiveMessage {
    [self reloadTableView];
}

- (void)reloadTableView {
    [self.tableView reloadData];
    if ([[[self.conversation objectForKey:kComments] objectForKey:kData] count] != 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[self.conversation objectForKey:kComments] objectForKey:kData] count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


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
    return ([[[self.conversation objectForKey:kComments] objectForKey:kData] count]== 0) ? 0 :[[[self.conversation objectForKey:kComments] objectForKey:kData] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *roomCellIdentifier = @"RoomCellIdentifier";
    NSDictionary *message = [[[self.conversation objectForKey:kComments] objectForKey:kData] objectAtIndex:indexPath.row];
       UITableViewCell *cell = (ChatRoomCell *)[tableView dequeueReusableCellWithIdentifier:roomCellIdentifier];
        if (cell == nil){
            cell = [[ChatRoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:roomCellIdentifier];
        }
        [(ChatRoomCell *)cell handleParametersForCellWithFBMessage:message andIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *message = [[[self.conversation objectForKey:kComments] objectForKey:kData] objectAtIndex:indexPath.row];
    NSString *chatString = [message objectForKey:kMessage];
    return [ChatRoomCell configureHeightForCellWithMessage:chatString];
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
