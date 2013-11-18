//
//  DialogsViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 29/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "DialogsViewController.h"
#import "DetailDialogsViewController.h"
#import "DialogsCell.h"
#import "FBService.h"
#import "FBStorage.h"
#import "QBService.h"
#import "QBStorage.h"

@interface DialogsViewController () <UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSArray *otherUsers;
@property (nonatomic, strong) NSMutableArray *searchContent;

@end

@implementation DialogsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fillTableView) name:CAChatDidReceiveOrSendMessageNotification object:nil];
    self.friends = [self sortingUsers:[[FBStorage shared] friends]];
    self.searchContent = [self.friends mutableCopy];
    self.otherUsers = [[QBStorage shared] otherUsers];
}

- (void)fillTableView {
    self.otherUsers = [QBStorage shared].otherUsers;
    [self.tableView reloadData];
}
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = [[NSString alloc] init];
    switch (section) {
        case 0:
            title = @"Friends";
            break;
        case 1:
            title = @"Other";
            break;
            
        default:
            break;
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger rows = 0;
    switch (section) {
        case 0:
            rows = [self.searchContent count];
            break;
        case 1:
            rows = [self.otherUsers count];
            break;
            
        default:
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DialogsCellIdentifier = @"DialogsCell";
    DialogsCell *cell = [tableView dequeueReusableCellWithIdentifier:DialogsCellIdentifier forIndexPath:indexPath];
    
    switch ([indexPath section]) {
        case 0:{
            NSDictionary *friend = [self.searchContent objectAtIndex:indexPath.row];
            [DialogsCell configureDialogsCell:cell forIndexPath:indexPath forFriend:friend];
        }
            break;
            
        case 1:{
            NSDictionary *user = [self.otherUsers objectAtIndex:indexPath.row];
            [DialogsCell configureDialogsCell:cell forIndexPath:indexPath forFriend:user];
        }
            break;
            
        default:
            break;
    }
    return cell;
}


#pragma mark -
#pragma mark Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.searchBar resignFirstResponder];
    self.searchBar.showsCancelButton = NO;
    
    [self performSegueWithIdentifier:kDetailDialogSegueIdentifier sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSMutableDictionary *user;
    NSMutableDictionary *conversation;
    NSIndexPath *indexPath = (NSIndexPath *)sender;
    switch (indexPath.section) {
        case 0:
        {
            user = [self.searchContent objectAtIndex:indexPath.row];
            conversation = [FBService findFBConversationWithFriend:user];
            ((DetailDialogsViewController *)segue.destinationViewController).isFacebookChat = YES;
        }
            break;
        case 1:
        {
            user = [self.otherUsers objectAtIndex:indexPath.row];
            conversation = [[QBService defaultService] findConversationWithFriend:user];
            ((DetailDialogsViewController *)segue.destinationViewController).isFacebookChat = NO;
        }
            break;
            
        default:
            break;
    }
    
    ((DetailDialogsViewController *)segue.destinationViewController).currentUser = user;
    ((DetailDialogsViewController *)segue.destinationViewController).conversation = conversation;
}


#pragma mark -
#pragma mark UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchingString:(NSString *)source inString:(NSString *)searchString {
    BOOL answer;
    NSRange range = [source rangeOfString:searchString options:NSCaseInsensitiveSearch];
    if (range.location == NSNotFound) {
        answer = NO;
    } else {
        answer = YES;
    }
    return answer;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchContent = [self.friends mutableCopy];
    
    if ([searchText isEqualToString:@""]) {
        [self.tableView reloadData];
    } else {
        NSMutableArray *deleted = [[NSMutableArray alloc] init];
        for (NSDictionary *user in self.searchContent) {
            if (![self searchingString:[user objectForKey:kName] inString:searchText]) {
                [deleted addObject:user];
            }
        }
        [self.searchContent removeObjectsInArray:deleted];
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
}


#pragma mark -
#pragma mark Sort

- (NSArray *)sortingUsers:(NSArray *)users {
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:kLastName ascending:YES];
   return [users sortedArrayUsingDescriptors:@[descriptor]];
}

@end
