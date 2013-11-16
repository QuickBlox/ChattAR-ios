//
//  QBService.h
//  ChattAR
//
//  Created by Igor Alefirenko on 25/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBService : NSObject <QBChatDelegate>

@property (nonatomic, assign) BOOL *userIsJoinedChatRoom;

+ (instancetype)defaultService;


#pragma mark -
#pragma  mark Messages

- (void)sendMessage:(NSString *)message toUser:(NSUInteger)userID option:(id)option;
- (void)sendmessage:(NSString *)message toChatRoom:(QBChatRoom *)room quote:(id)quote;


#pragma mark -
#pragma mark LogIn & LogOut

- (void)loginWithUser:(QBUUser *)user;

#pragma mark -
#pragma mark Operations

- (void)chatCreateOrJoinRoomWithName:(NSString *)roomName andNickName:(NSString *)nickname;

- (NSMutableDictionary *)findConversationToUserWithMessage:(QBChatMessage *)message;
- (NSMutableDictionary *)findConversationWithFriend:(NSMutableDictionary *)aFriend;


#pragma mark -
#pragma mark Archiving (JSON Parsing)

- (NSString *)archiveMessageData:(NSMutableDictionary *)messageData;
- (NSMutableDictionary *)unarchiveMessageData:(NSString *)messageData;

@end
