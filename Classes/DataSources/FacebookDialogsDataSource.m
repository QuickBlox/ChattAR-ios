//
//  FacebookDialogsDataSource.m
//  ChattAR
//
//  Created by Igor Alefirenko on 12/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "FacebookDialogsDataSource.h"
#import "ChatRoomCell.h"

@implementation FacebookDialogsDataSource


#pragma mark -
#pragma mark Table View Data Source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *data = [[self.conversation objectForKey:kComments] objectForKey:kData];
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *roomCellIdentifier = @"RoomCellIdentifier";
    
    NSDictionary *message = [[[self.conversation objectForKey:kComments] objectForKey:kData] objectAtIndex:indexPath.row];
    
    ChatRoomCell *cell = (ChatRoomCell *)[tableView dequeueReusableCellWithIdentifier:roomCellIdentifier];
    if (cell == nil){
        cell = [[ChatRoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:roomCellIdentifier];
    }
    [cell handleParametersForCellWithFBMessage:message andIndexPath:indexPath];
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSDictionary *message = [[[self.conversation objectForKey:kComments] objectForKey:kData] objectAtIndex:indexPath.row];
//    NSString *messageText = [message objectForKey:kMessage];
//    return [ChatRoomCell configureHeightForCellWithMessage:messageText];
//}

@end
