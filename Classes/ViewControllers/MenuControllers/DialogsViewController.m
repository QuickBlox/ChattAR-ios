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
    self.friends = [[FBStorage shared] friends];
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
            rows = [[FBStorage shared].friends count];
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
    // Configure the cell...
    return cell;
}

- (DialogsCell *)configureDialogsCell:(DialogsCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    AsyncImageView *loadedImageView = [[AsyncImageView alloc] init];
    [loadedImageView setImageURL:[NSURL URLWithString:[[FBStorage shared].friendsAvatarsURLs objectAtIndex:indexPath.row]]];
    NSString *name = [NSString stringWithFormat:@"%@", [[[FBStorage shared].friends objectAtIndex:indexPath.row] objectForKey:kFirstName]];
    NSString *lastName = [NSString stringWithFormat:@"%@", [[[FBStorage shared].friends objectAtIndex:indexPath.row] objectForKey:kLastName]];
    
    if (cell.asyncView == nil) {
        cell.asyncView = [[AsyncImageView alloc] init];
    }
    [cell.asyncView setImageURL:[NSURL URLWithString:[[FBStorage shared].friendsAvatarsURLs objectAtIndex:indexPath.row]]];
    cell.name.text = [NSString stringWithFormat:@"%@ %@", name, lastName];
    cell.detailTextLabel.text = @"Friends Group";
    
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.friend = [self.friends objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"DialogSegue" sender:self.friend];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ((DetailDialogsViewController *)segue.destinationViewController).myFriend = sender;
}

@end
