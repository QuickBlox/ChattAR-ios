//
//  DialogsDataSource.m
//  ChattAR
//
//  Created by Igor Alefirenko on 28/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "DialogsDataSource.h"
#import "DialogsCell.h"

@implementation DialogsDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = [[NSString alloc] init];
    switch (section) {
        case 0:
            if ([self.friends count] == 0) {
                title = @"";
                break;
            }
            title = @"Friends";
            break;
        case 1:
            if ([self.otherUsers count] == 0) {
                title = @"";
                break;
            }
            title = @"Others";
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


@end
