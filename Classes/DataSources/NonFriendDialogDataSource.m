//
//  QuickBloxDialogsDataSource.m
//  ChattAR
//
//  Created by Igor Alefirenko on 11/11/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "NonFriendDialogDataSource.h"
#import "ChatRoomCell.h"
#import "QBService.h"

@implementation NonFriendDialogDataSource


#pragma mark -
#pragma mark Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *messages = [self.conversation objectForKey:kMessage];
    return [messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"NonFriendCellIdentifier";
    
    QBChatMessage *message = [[self.conversation objectForKey:kMessage] objectAtIndex:indexPath.row];
    ChatRoomCell *cell = (ChatRoomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ChatRoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary *dict = [[QBService defaultService] unarchiveMessageData:message.text];
    
    [cell handleParametersForCellWithQBMessage:message andIndexPath:indexPath];
    [cell bubleImageForDialogWithUserID:dict[kId]];
    return cell;
}

@end
