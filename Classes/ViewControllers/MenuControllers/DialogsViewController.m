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
#import "AsyncImageView.h"

@interface DialogsViewController ()

@property (nonatomic, strong) NSMutableDictionary *friend;

@end

@implementation DialogsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.friends = [self sortingUsers:[[FBStorage shared] friends]];
    self.searchContent = [self.friends mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
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
            rows = 0;
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
        case 0:
            cell = [self configureDialogsCell:cell forIndexPath:indexPath];
            break;
            case 1:
            break;
            
        default:
            break;
    }
    return cell;
}

- (DialogsCell *)configureDialogsCell:(DialogsCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    NSString *name = [NSString stringWithFormat:@"%@", [[self.searchContent objectAtIndex:indexPath.row] objectForKey:kFirstName]];
    NSString *lastName = [NSString stringWithFormat:@"%@", [[self.searchContent objectAtIndex:indexPath.row] objectForKey:kLastName]];
    [cell.asyncView setImageURL:[NSURL URLWithString:[[self.searchContent objectAtIndex:indexPath.row] objectForKey:kPhoto]]];
    cell.name.text = [NSString stringWithFormat:@"%@ %@", name, lastName];
    cell.detailTextLabel.text = @"Friends Group";
    
    return cell;
}


#pragma mark -
#pragma mark Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchBar resignFirstResponder];
    self.searchBar.showsCancelButton = NO;
    self.friend = [self.searchContent objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"DialogSegue" sender:self.friend];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ((DetailDialogsViewController *)segue.destinationViewController).myFriend = sender;
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //search button
}


#pragma mark -
#pragma mark Sort

-(NSArray *)sortingUsers:(NSArray *)users{
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:kLastName ascending:YES];
   return [users sortedArrayUsingDescriptors:@[descriptor]];
}

@end
