//
//  DialogsDataSource.m
//  ChattAR
//
//  Created by Igor Alefirenko on 28/11/2013.
//  Copyright (c) 2013 Quickblox. All rights reserved.
//

#import "DialogsDataSource.h"
#import "DialogsCell.h"

@implementation DialogsDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DialogsCellIdentifier = @"DialogsCell";
    DialogsCell *cell = [tableView dequeueReusableCellWithIdentifier:DialogsCellIdentifier forIndexPath:indexPath];
    
    NSDictionary *user = [self.allUsers objectAtIndex:indexPath.row];
    [DialogsCell configureDialogsCell:cell forIndexPath:indexPath forUser:user];

    return cell;
}


@end
