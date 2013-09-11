//
//  TrendingDataSource.m
//  ChattAR
//
//  Created by Igor Alefirenko on 09/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "ChatViewController.h"
#import "TrendingDataSource.h"

@implementation TrendingDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.chatRooms count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrendingCell"];
    NSUInteger row = [indexPath row];
    cell.imageView.image = [UIImage imageNamed:@"trendings_uicon@2x.png"];
    QBCOCustomObject *currentObject = [self.chatRooms objectAtIndex:row];
    cell.textLabel.text = [currentObject.fields objectForKey:@"name"];
    cell.detailTextLabel.text = @"Trending room";
    return cell;
}


@end
