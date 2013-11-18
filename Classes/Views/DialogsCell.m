//
//  DialogsCell.m
//  ChattAR
//
//  Created by Igor Alefirenko on 29/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "DialogsCell.h"

@implementation DialogsCell

+ (void)configureDialogsCell:(DialogsCell *)cell forIndexPath:(NSIndexPath *)indexPath forFriend:(NSDictionary *)aFriend
{
    [cell.asyncView setImageURL:[NSURL URLWithString:[aFriend objectForKey:kPhoto]]];
    cell.name.text = [aFriend objectForKey:kName];
}


@end
