//
//  DialogsCell.m
//  ChattAR
//
//  Created by Igor Alefirenko on 29/10/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "DialogsCell.h"
#import "QBService.h"
#import "FBStorage.h"
#import "QBStorage.h"
#import "Utilites.h"


@implementation DialogsCell

+ (void)configureDialogsCell:(DialogsCell *)cell forIndexPath:(NSIndexPath *)indexPath forUser:(NSDictionary *)user
{
    // cancel previous user's avatar loading
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.asyncView];
    [cell.asyncView setImage:[UIImage imageNamed:@"human.png"]];
    
    // load user's avatar
    [cell.asyncView setImageURL:[NSURL URLWithString:[user objectForKey:kPhoto]]];
    
    // set user's text
    cell.name.text = [user objectForKey:kName];
    
    // chose conversation type
    NSDictionary *conversation = nil;
    if ([user[kIsFriend] boolValue]) {
        
        // facebook conversation type
        conversation = [FBStorage shared].allFriendsHistoryConversation[user[kId]];
        NSMutableArray *messages = (conversation[kComments])[kData];
        NSMutableDictionary *lastMessageDictionary = [messages lastObject];
        
        // date time
        NSString *dateString = lastMessageDictionary[kCreatedTime];
        NSDate *date = [[Utilites shared].dateFormatter dateFromString:dateString];
        NSString *timeAgo = [[Utilites shared] fullFormatPassedTimeFromDate:date];
        cell.dateTime.text = timeAgo;
        
        // reply arrow hidden or not
        NSString *messageFromUserID = (lastMessageDictionary[kFrom])[kId];
        if ([messageFromUserID isEqualToString:[FBStorage shared].me[kId]]) {
            cell.replyArrow.hidden = NO;
        } else {
            cell.replyArrow.hidden = YES;
        }
        // user's message text
        NSString *lastMessage = lastMessageDictionary[kMessage];
        cell.userMessage.text = lastMessage;
    } else {
        // quickblox conversation type
        conversation = [QBStorage shared].allQuickBloxHistoryConversation[user[kId]];
        NSMutableArray *messages = conversation[kMessage];
        QBChatMessage *lastMessage = [messages lastObject];
        
        // date time
        NSString *timeAgo = [[Utilites shared] fullFormatPassedTimeFromDate:lastMessage.datetime];
        cell.dateTime.text = timeAgo;
        
        NSDictionary *messageBody = [[QBService defaultService] unarchiveMessageData:lastMessage.text];
        
        NSString *messageFromUserID = messageBody[kId];
        if ([messageFromUserID isEqualToString:[FBStorage shared].me[kId]]) {
            cell.replyArrow.hidden = NO;
        } else {
            cell.replyArrow.hidden = YES;
        }
        NSString *userMessage = messageBody[kMessage];
        cell.userMessage.text = userMessage;
    }
    
    if ([conversation[kUnread] integerValue] > 0) {
        cell.backgroundColor = [UIColor colorWithRed:62/255.0 green:136/255.0 blue:203/255.0 alpha:0.09];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
}

@end
