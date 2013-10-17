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
    cell.imageView.image = [UIImage imageNamed:@"upic_local.png"];
    QBCOCustomObject *currentObject = [self.chatRooms objectAtIndex:row];
    cell.textLabel.text = [currentObject.fields objectForKey:kName];
    cell.detailTextLabel.text = [self distanceFormatter:[self.distances objectAtIndex:row]];
    
    return cell;
}

- (NSString *)distanceFormatter:(NSInteger)distance{
    NSString *formatedDistance;
    if (distance <=999) {
        formatedDistance = [NSString stringWithFormat:@"%d m", distance];
    } else{
        distance = round(distance/1000);
        formatedDistance = [NSString stringWithFormat:@"%d km",distance];
    }
    return formatedDistance;
}

@end
