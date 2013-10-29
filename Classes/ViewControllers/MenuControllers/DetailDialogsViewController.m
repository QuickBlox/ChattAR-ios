//
//  DetailDialogsViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 29/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "DetailDialogsViewController.h"

@interface DetailDialogsViewController ()

@end

@implementation DetailDialogsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = [NSString stringWithFormat:@"%@ %@", [self.myFriend objectForKey:kFirstName], [self.myFriend objectForKey:kLastName]];
    [self configureInputTextViewLayer];
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
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendMessage:(id)sender {
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
    return 13;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"DialogCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = @"Title";
    cell.detailTextLabel.text = @"Subtitle";
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
