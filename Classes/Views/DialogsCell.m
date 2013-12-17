//
//  DialogsCell.m
//  ChattAR
//
//  Created by Igor Alefirenko on 29/10/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "DialogsCell.h"

@implementation DialogsCell

+ (void)configureDialogsCell:(DialogsCell *)cell forIndexPath:(NSIndexPath *)indexPath forFriend:(NSDictionary *)aFriend
{
    // cancel previous user's avatar loading
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.asyncView];
    [cell.asyncView setImage:[UIImage imageNamed:@"human.png"]];
    
    // load user's avatar
    [cell.asyncView setImageURL:[NSURL URLWithString:[aFriend objectForKey:kPhoto]]];
    
    // set user's text
    cell.name.text = [aFriend objectForKey:kName];
}


@end
