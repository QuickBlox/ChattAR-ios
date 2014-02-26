//
//  DialogsViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 29/10/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "DialogsViewController.h"
#import "DetailDialogsViewController.h"
#import "NSMutableArray+MoveObjects.h"
#import "DialogsDataSource.h"
#import "ChatRoomStorage.h"
#import "FBService.h"
#import "FBStorage.h"
#import "QBService.h"
#import "QBStorage.h"
#import "Utilites.h"

@interface DialogsViewController () <UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UILabel *noResultsLabel;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *allUsers;
@property (nonatomic, strong) NSMutableArray *searchedUsers;
@property (nonatomic, strong) DialogsDataSource *dialogsDataSource;

@end

@implementation DialogsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:KFlurryEventDialogsScreenWasOpened];
    self.searchBar.autocorrectionType= UITextAutocorrectionTypeNo;
    self.dialogsDataSource = [[DialogsDataSource alloc] init];
    self.tableView.dataSource = self.dialogsDataSource;
    [self reloadUsers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:CADialogsHideUnreadMessagesLabelNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fillTableView:) name:CAChatDidReceiveOrSendMessageNotification object:nil];
    
    self.dialogsDataSource.allUsers = self.allUsers;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    [self.tableView reloadData];
}

- (void)reloadUsers
{
    NSMutableArray *friends = [FBStorage shared].friends;
    NSMutableArray *otherUsers = [QBStorage shared].otherUsers;
    
    self.allUsers = [NSMutableArray arrayWithArray:friends];
    [self.allUsers addObjectsFromArray:otherUsers];
    self.allUsers = [[self sortingUsers:self.allUsers] mutableCopy];
}


#pragma mark -
#pragma mark Notifications 

- (void)fillTableView:(NSNotification *)aNotification
{
    if (self.searchedUsers != nil) {
        return;
    }
    [self reloadUsers];
    self.dialogsDataSource.allUsers = self.allUsers;
    self.searchedUsers = nil;
    [self.tableView reloadData];
}

- (void)reloadTableView {
    [self.tableView reloadData];
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
    NSIndexPath *indexPath = (NSIndexPath *)sender;

    NSMutableDictionary *user = [self.searchedUsers objectAtIndex:indexPath.row];
    if (user == nil) {
        user = [self.allUsers objectAtIndex:indexPath.row];
    }
    
    BOOL isFriend =[user[kIsFriend] boolValue];
     NSMutableDictionary *conversation;
    if (isFriend) {
        conversation = [FBService findFBConversationWithFriend:user];
        ((DetailDialogsViewController *)segue.destinationViewController).isChatWithFacebookFriend = YES;
    } else {
        conversation = [[QBService defaultService] findConversationWithUser:user];
        ((DetailDialogsViewController *)segue.destinationViewController).isChatWithFacebookFriend = NO;
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
- (BOOL)searchingString:(NSString *)source inString:(NSString *)searchString
{
    NSString *sourceString = [source stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    
    NSRange range = [sourceString rangeOfString:searchString options:NSCaseInsensitiveSearch];
    if (range.location == NSNotFound) {
        return NO;
    }
    return YES;
}

- (NSMutableArray *)searchText:(NSString *)text  inArray:(NSMutableArray *)array {
    NSMutableArray *found = [[NSMutableArray alloc] init];

    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([self searchingString:obj[kName] inString:text]) {
            [found addObject:obj];
        }
    }];
    return found;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.noResultsLabel.hidden = YES;
    
    self.searchedUsers = [self.allUsers mutableCopy];
    self.dialogsDataSource.allUsers = self.searchedUsers;

    if ([self.searchedUsers count] == 0) {
        self.noResultsLabel.hidden = NO;
    } else if (searchText.length == 0) {
        self.noResultsLabel.hidden = YES;
        [self.tableView reloadData];
    } else {
        NSMutableArray *foundedUser = [self searchText:searchText inArray:self.searchedUsers];
        [self.searchedUsers removeAllObjects];
        [self.searchedUsers addObjectsFromArray:foundedUser];
    
        if ([self.searchedUsers count] == 0) {
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

- (NSArray *)sortingUsers:(NSArray *)users
{
  NSArray *sortedUsers = [users sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        double timeInterval1 = 0;
        double timeInterval2 = 0;
      
        NSString *dateString1 = obj1[kLastMessageDate];
        if (dateString1 != nil) {
            NSDate *date1 = [[Utilites shared].dateFormatter dateFromString:dateString1];
            timeInterval1 = [date1 timeIntervalSince1970];
        }
        
        NSString *dateString2 = obj2[kLastMessageDate];
        if (dateString2 != nil) {
            NSDate *date2 = [[Utilites shared].dateFormatter dateFromString:dateString2];
            timeInterval2 = [date2 timeIntervalSince1970];
        }
        
        if (timeInterval1 > timeInterval2) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ( timeInterval1 < timeInterval2) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
    return sortedUsers;
}

@end
