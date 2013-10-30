//
//  DetailDialogsViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 29/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "DetailDialogsViewController.h"
#import "ChatRoomCell.h"
#import "FBStorage.h"
#import "QBService.h"
#import "LocationService.h"

@interface DetailDialogsViewController ()

@end

@implementation DetailDialogsViewController
@synthesize quote;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[QBService defaultService] dialogMessages] == nil) {
        self.chatHistory = [[NSMutableArray alloc] init];
    } else {
        self.chatHistory = [[QBService defaultService] dialogMessages];
    }
	// Do any additional setup after loading the view.
    self.title = [NSString stringWithFormat:@"%@ %@", [self.myFriend objectForKey:kFirstName], [self.myFriend objectForKey:kLastName]];
    [self configureInputTextViewLayer];
    [QBChat instance].delegate = self;
    [QBUsers userWithFacebookID:[self.myFriend objectForKey:kId] delegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureInputTextViewLayer{
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
        QBChatMessage *message = [QBChatMessage message];
        message.recipientID = [QBService defaultService].qbFriend.ID;
        
        NSString *myLatitude = [[NSString alloc] initWithFormat:@"%f",[[LocationService shared] getMyCoorinates].latitude];
        NSString *myLongitude = [[NSString alloc] initWithFormat:@"%f", [[LocationService shared] getMyCoorinates].longitude];
        NSString *userName =  [NSString stringWithFormat:@"%@ %@",[[FBStorage shared].currentFBUser objectForKey:kFirstName], [[FBStorage shared].currentFBUser objectForKey:kLastName]];
        NSString *urlString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", [[FBStorage shared].currentFBUser objectForKey:kId], [FBStorage shared].accessToken];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:myLatitude forKey:kLatitude];
        [dict setValue:myLongitude forKey:kLongitude];
        [dict setValue:urlString forKey:kUserPhotoUrl];
        [dict setValue:userName forKey:kUserName];
        [dict setValue:self.inputMessageField.text forKey:kMessage];
        // formatting to JSON:
        NSError *error = nil;
        NSData* nsdata = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString* jsonString =[[NSString alloc] initWithData:nsdata encoding:NSUTF8StringEncoding];
        message.text = jsonString;
        [[QBChat instance] sendMessage:message];
        [self.chatHistory addObject:message];
        [[QBService defaultService] setDialogMessages:self.chatHistory];
        self.inputMessageField.text = @"";
        [self.inputMessageField resignFirstResponder];
        [self reloadTableView];
    }
}


#pragma mark -
#pragma mark QBChatDelegate


- (void)chatDidReceiveMessage:(QBChatMessage *)message{
    [self.chatHistory addObject:message];
    [[QBService defaultService] setDialogMessages:self.chatHistory];
    [self reloadTableView];
}

-(void)reloadTableView {
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatHistory count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

-(void)completedWithResult:(Result *)result{
    if (result.success) {
        if ([result isKindOfClass:[QBUUserResult class]]) {
            QBUUserResult *userResult = (QBUUserResult *)result;
            [QBService defaultService].qbFriend = userResult.user;
        }
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.chatHistory count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *roomCellIdentifier = @"RoomCellIdentifier";
    QBChatMessage *qbMessage = [_chatHistory objectAtIndex:[indexPath row]];
       UITableViewCell *cell = (ChatRoomCell *)[tableView dequeueReusableCellWithIdentifier:roomCellIdentifier];
        if (cell == nil){
            cell = [[ChatRoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:roomCellIdentifier];
        }
        [(ChatRoomCell *)cell handleParametersForCellWithMessage:qbMessage andIndexPath:indexPath];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *chatString = [[_chatHistory objectAtIndex:indexPath.row] text];
    NSData *data = [chatString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *currentMessage = [dictionary objectForKey:kMessage];

    return [ChatRoomCell configureHeightForCellWithDictionary:currentMessage];
}


#pragma mark -
#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
