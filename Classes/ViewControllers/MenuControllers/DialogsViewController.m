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
@property (nonatomic, strong) NSArray *searchContent;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *otherUsers;

@end

@implementation DialogsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fillTableView) name:CAChatDidReceiveOrSendMessageNotification object:nil];
    
    self.searchContent = [self sortingUsers:[[FBStorage shared] friends]];
    self.friends = [self.searchContent mutableCopy];
    NSArray *users = [[QBStorage shared] otherUsers];
    self.otherUsers = [users mutableCopy];
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
            rows = [self.friends count];
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
            NSDictionary *friend = [self.friends objectAtIndex:indexPath.row];
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
            user = [self.friends objectAtIndex:indexPath.row];
            conversation = [FBService findFBConversationWithFriend:user];
            ((DetailDialogsViewController *)segue.destinationViewController).isChatWithFacebookFriend = YES;
        }
            break;
        case 1:
        {
            user = [self.otherUsers objectAtIndex:indexPath.row];
            conversation = [[QBService defaultService] findConversationWithFriend:user];
            ((DetailDialogsViewController *)segue.destinationViewController).isChatWithFacebookFriend = NO;
        }
            break;
            
        default:
            break;
    }
    
    ((DetailDialogsViewController *)segue.destinationViewController).opponent = user;
    ((DetailDialogsViewController *)segue.destinationViewController).conversation = conversation;
}


#pragma mark -
#pragma mark UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    return YES;
}

// options:
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

- (NSMutableArray *)objectsToDeleteFromArray:(NSMutableArray *)array text:(NSString *)text {
    NSMutableArray *deleted = [[NSMutableArray alloc] init];
    for (NSDictionary *user in array) {
        if (![self searchingString:[user objectForKey:kName] inString:text]) {
            [deleted addObject:user];
        }
    }
    return deleted;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.friends = [self.searchContent mutableCopy];
    self.otherUsers = [[QBStorage shared].otherUsers mutableCopy];
    if ([searchText isEqualToString:@""]) {
        [self.tableView reloadData];
    } else {
        NSMutableArray *friendsToDelete = [self objectsToDeleteFromArray:self.friends text:searchText];
        NSMutableArray *opponentsToDelete = [self objectsToDeleteFromArray:self.otherUsers text:searchText];
        [self.friends removeObjectsInArray:friendsToDelete];
        [self.otherUsers removeObjectsInArray:opponentsToDelete];
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
