//
//  QBService.h
//  ChattAR
//
//  Created by Igor Alefirenko on 25/10/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBService : NSObject <QBChatDelegate, QBActionStatusDelegate>

@property (nonatomic, assign) BOOL userIsJoinedChatRoom;
@property (nonatomic, strong) NSTimer *presenceTimer;

+ (instancetype)defaultService;


#pragma mark -
#pragma mark Requests

- (void)usersWithFacebookIDs:(NSArray *)facebookIDs;

#pragma mark -
#pragma  mark Messages

- (void)sendMessage:(NSString *)message toUser:(NSUInteger)userID option:(id)option;
- (void)sendMessage:(NSString *)message toChatRoom:(QBChatRoom *)room quote:(id)quote;
- (void)sendPushNotificationWithMessage:(NSString *)message toUser:(NSString *)quickbloxUserID roomName:(NSString *)roomName;


#pragma mark -
#pragma mark LogIn & LogOut

- (void)loginWithUser:(QBUUser *)user;
- (void)loginToChatFromBackground;

#pragma mark -
#pragma mark Operations

- (void)chatCreateOrJoinRoomWithName:(NSString *)roomName andNickName:(NSString *)nickname;

- (NSMutableDictionary *)findConversationToUserWithMessage:(QBChatMessage *)message;
- (NSMutableDictionary *)findConversationWithUser:(NSMutableDictionary *)aFriend;
- (NSMutableDictionary *)findUserWithID:(NSString *)ID;


#pragma mark -
#pragma mark Loading and handling Facebook users

- (void)loadAndHandleOtherFacebookUsers:(NSArray *)userIDs;


#pragma mark -
#pragma mark Archiving (JSON Parsing)

- (NSString *)archiveMessageData:(NSMutableDictionary *)messageData;
- (NSMutableDictionary *)unarchiveMessageData:(NSString *)messageData;

@end
