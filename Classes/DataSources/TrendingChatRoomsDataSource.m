//
//  TrendingDataSource.m
//  ChattAR
//
//  Created by Igor Alefirenko on 09/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "ChatViewController.h"
#import "TrendingChatRoomsDataSource.h"
#import "TrendingCell.h"

@implementation TrendingChatRoomsDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chatRooms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *trendingCellIdentifier = @"TrendingCell";
    TrendingCell *cell = (TrendingCell *)[tableView dequeueReusableCellWithIdentifier:trendingCellIdentifier];
    cell.backgroundColor = [UIColor whiteColor];
    NSUInteger row = [indexPath row];
    QBCOCustomObject *currentObject = [self.chatRooms objectAtIndex:row];
    cell.nameLabel.text = [currentObject.fields objectForKey:kName];
    cell.rankLabel.text = [NSString stringWithFormat:@"%@",[currentObject.fields objectForKey:kRank]];
    
    return cell;
}

@end
