//
//  ChatRoomDataSource.m
//  ChattAR
//
//  Created by Igor Alefirenko on 28/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "ChatRoomDataSource.h"
#import "ChatRoomCell.h"
#import "QuotedChatRoomCell.h"

@implementation ChatRoomDataSource


#pragma mark -
#pragma mark Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_chatHistory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *roomCellIdentifier = @"RoomCellIdentifier";
    static NSString *quotedRoomCellIdentifier = @"quotedRoomCellIdentifier";
    
    QBChatMessage *qbMessage = [_chatHistory objectAtIndex:[indexPath row]];
    NSString *string = [NSString stringWithFormat:@"%@", qbMessage.text];
    // JSON parsing
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    // There are Two different cells: "Simple" and "Quoted"
    if ([jsonDict objectForKey:kQuote] == nil) {
        cell = (ChatRoomCell *)[tableView dequeueReusableCellWithIdentifier:roomCellIdentifier];
        if (cell == nil){
            cell = [[ChatRoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:roomCellIdentifier];
        }
        [(ChatRoomCell *)cell handleParametersForCellWithQBMessage:qbMessage andIndexPath:indexPath];
    } else {
        cell = (QuotedChatRoomCell *)[tableView dequeueReusableCellWithIdentifier:quotedRoomCellIdentifier];
        if (cell == nil) {
            cell = [[QuotedChatRoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:quotedRoomCellIdentifier];
        }
        [(QuotedChatRoomCell *)cell handleParametersForCellWithMessage:qbMessage andIndexPath:indexPath];
    }
    return cell;
}

@end
