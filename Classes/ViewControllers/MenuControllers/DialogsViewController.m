//
//  DialogsViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 29/10/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "DialogsViewController.h"
#import "DetailDialogsViewController.h"
#import "DialogsDataSource.h"
#import "FBService.h"
#import "FBStorage.h"
#import "QBService.h"
#import "QBStorage.h"

@interface DialogsViewController () <UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UILabel *noResultsLabel;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *otherUsers;
@property (nonatomic, strong) DialogsDataSource *dialogsDataSource;

@end

@implementation DialogsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:KFlurryEventDialogsScreenWasOpened];
    self.dialogsDataSource = [[DialogsDataSource alloc] init];
    self.tableView.dataSource = self.dialogsDataSource;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fillTableView) name:CAChatDidReceiveOrSendMessageNotification object:nil];
    
    NSArray *sortUsers = [self sortingUsers:[FBStorage shared].friends];
    [FBStorage shared].friends = [NSMutableArray arrayWithArray:sortUsers];
    self.friends = [FBStorage shared].friends;
    self.otherUsers = [[QBStorage shared].otherUsers mutableCopy];
    
    self.dialogsDataSource.friends = self.friends;
    self.dialogsDataSource.otherUsers = self.otherUsers;
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Notifications 

- (void)fillTableView {
    self.otherUsers = [QBStorage shared].otherUsers;
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Table view data source

/////////////lol/////////

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
    self.noResultsLabel.hidden = YES;
    self.friends = [[FBStorage shared].friends mutableCopy];

    self.dialogsDataSource.friends = self.friends;
    self.otherUsers = [[QBStorage shared].otherUsers mutableCopy];
    self.dialogsDataSource.otherUsers = self.otherUsers;
    
    if ([self.friends count] == 0 && [self.otherUsers count] == 0) {
        self.noResultsLabel.hidden = NO;
    } else if ([searchText isEqualToString:@""]) {
        self.noResultsLabel.hidden = YES;
        [self.tableView reloadData];
    } else {
        NSMutableArray *friendsToDelete = [self objectsToDeleteFromArray:self.friends text:searchText];
        NSMutableArray *opponentsToDelete = [self objectsToDeleteFromArray:self.otherUsers text:searchText];
        [self.friends removeObjectsInArray:friendsToDelete];
        [self.otherUsers removeObjectsInArray:opponentsToDelete];
        if ([self.friends count] == 0 && [self.otherUsers count] == 0) {
            self.noResultsLabel.hidden = NO;
        }
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
