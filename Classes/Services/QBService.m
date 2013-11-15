//
//  QBService.m
//  ChattAR
//
//  Created by Igor Alefirenko on 25/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "QBService.h"
#import "FBStorage.h"
#import "QBStorage.h"
#import "LocationService.h"

@implementation QBService

+ (instancetype)defaultService {
    static QBService *defaultQBService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultQBService = [[self alloc] init];
    });
    return defaultQBService;
}

- (id)init {
    self = [super init];
    if (self) {
        [QBChat instance].delegate = self;
        self.userIsJoinedChatRoom = NO;
    }
    return self;
}


#pragma mark -
#pragma mark Messages

- (void)sendMessage:(NSString *)message toUser:(NSUInteger)userID option:(id)option {
    QBChatMessage *msg = [QBChatMessage message];

    NSDate *date = [NSDate date];
    msg.datetime = date;
    
    msg.recipientID = userID;
    NSDictionary *currentUser = [FBStorage shared].me;
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", [currentUser objectForKey:kId], [FBStorage shared].accessToken];
    NSString *facebookID = [[FBStorage shared].me objectForKey:kId];
    NSString *quickbloxID = [NSString stringWithFormat:@"%i", [QBStorage shared].me.ID];
    // create message:
    NSMutableDictionary *messageDictionary = [[NSMutableDictionary alloc] init];
    [messageDictionary setObject:message forKey:kMessage];
    [messageDictionary setObject:[currentUser objectForKey:kName] forKey:kUserName];
    [messageDictionary setObject:urlString forKey:kPhoto];
    [messageDictionary setObject:facebookID forKey:kId];
    [messageDictionary setObject:quickbloxID forKey:kQuickbloxID];
    // formatting to JSON:
    NSString *jsonString = [self archiveMessageData:messageDictionary];
    msg.text = jsonString;
    
    [[QBChat instance] sendMessage:msg];
    [self cachingMessage:msg forUserID:option];
    [[NSNotificationCenter defaultCenter] postNotificationName:CAChatDidReceiveOrSendMessageNotification object:nil];
}

- (void)cachingMessage:(QBChatMessage *)message forUserID:(NSString *)userID {
    NSMutableDictionary *temporary = [[QBStorage shared].allQuickBloxHistoryConversation objectForKey:userID];
    if (temporary != nil) {
        NSMutableArray *messages = [temporary objectForKey:kMessage];
        [messages addObject:message];
        return;
    }
    NSMutableArray *messages = [[NSMutableArray alloc] initWithObjects:message, nil];
    temporary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:messages,kMessage, nil];
    [[QBStorage shared].allQuickBloxHistoryConversation setObject:temporary forKey:userID];
}


- (void)sendmessage:(NSString *)message toChatRoom:(QBChatRoom *)room quote:(id)quote {
    NSString *myLatitude = [[NSString alloc] initWithFormat:@"%f",[[LocationService shared] getMyCoorinates].latitude];
    NSString *myLongitude = [[NSString alloc] initWithFormat:@"%f", [[LocationService shared] getMyCoorinates].longitude];
    NSString *userName =  [NSString stringWithFormat:@"%@ %@",[[FBStorage shared].me objectForKey:kFirstName], [[FBStorage shared].me objectForKey:kLastName]];
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", [[FBStorage shared].me objectForKey:kId], [FBStorage shared].accessToken];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:myLatitude forKey:kLatitude];
    [dict setValue:myLongitude forKey:kLongitude];
    [dict setValue:urlString forKey:kPhoto];
    [dict setValue:userName forKey:kUserName];
    if (quote != nil) {
        [dict setValue:quote forKey:kQuote];
        quote = nil;
    }
    [dict setValue:message forKey:kMessage];
    [dict setValue:[[FBStorage shared].me objectForKey:kId] forKey:kId];
    NSString *quickbloxID = [NSString stringWithFormat:@"%i",[QBStorage shared].me.ID];
    [dict setValue:quickbloxID forKey:kQuickbloxID];
    // formatting to JSON:
    NSString* jsonString = [[QBService defaultService] archiveMessageData:dict];
    
    [[QBChat instance] sendMessage:jsonString toRoom:room];
}


#pragma mark -
#pragma mark Operations

- (NSMutableDictionary *)findConversationToUserWithMessage:(QBChatMessage *)message {
    NSMutableDictionary *messageData = [[QBService defaultService] unarchiveMessageData:message.text];
    NSString *userID = [messageData objectForKey:kId];
    NSMutableDictionary *conversation = [[QBStorage shared].allQuickBloxHistoryConversation objectForKey:userID];
    if (conversation == nil) {
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        conversation = [[NSMutableDictionary alloc] init];
        [conversation setObject:messages forKey:kMessage];
    }
    return conversation;
}

- (NSMutableDictionary *)findConversationWithFriend:(NSMutableDictionary *)aFriend {
    NSString *friendID = [aFriend objectForKey:kId];
    NSMutableDictionary *conversation = [[QBStorage shared].allQuickBloxHistoryConversation objectForKey:friendID];
    if (conversation == nil) {
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        conversation = [[NSMutableDictionary alloc] init];
        [conversation setObject:messages forKey:kMessage];
    }
    return conversation;
}


#pragma mark -
#pragma mark Archiving

- (NSString *)archiveMessageData:(NSMutableDictionary *)messageData {
    NSError *error = nil;
    NSData* nsdata = [NSJSONSerialization dataWithJSONObject:messageData options:NSJSONWritingPrettyPrinted error:&error];
    NSString* jsonString =[[NSString alloc] initWithData:nsdata encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSMutableDictionary *)unarchiveMessageData:(NSString *)messageData {
    NSData *dictData = [messageData dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *tempDict = [NSJSONSerialization JSONObjectWithData:dictData options:NSJSONReadingAllowFragments error:nil];
    return tempDict;
}


#pragma mark -
#pragma mark QBChatDelegate

- (void)chatDidReceiveMessage:(QBChatMessage *)message {
    NSMutableDictionary *messageData = [self unarchiveMessageData:message.text];
    NSString *facebookID = [messageData objectForKey:kId];
    [self cachingMessage:message forUserID:facebookID];
    [[NSNotificationCenter defaultCenter] postNotificationName:CAChatDidReceiveOrSendMessageNotification object:nil];
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoom:(NSString *)roomName {
    [[QBStorage shared].chatHistory addObject:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:CAChatRoomDidReceiveOrSendMessageNotification object:nil];
}

- (void)chatRoomDidLeave:(NSString *)roomName {
    NSLog(@"Did  Leave worked");
}
@end
