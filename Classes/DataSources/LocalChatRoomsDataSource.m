//
//  LocationDataSource.m
//  ChattAR
//
//  Created by Igor Alefirenko on 09/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "LocalChatRoomsDataSource.h"
#import "ChatViewController.h"

@implementation LocalChatRoomsDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.chatRooms count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *localCellIdentifier = @"LocalCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:localCellIdentifier];
    NSUInteger row = [indexPath row];
    cell.imageView.image = [UIImage imageNamed:@"upic_local@2x.png"];
    QBCOCustomObject *currentObject = [self.chatRooms objectAtIndex:row];
    cell.textLabel.text = [currentObject.fields objectForKey:kName];
    
    return cell;
}

@end
