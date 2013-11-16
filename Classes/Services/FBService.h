//
//  FBService.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 07.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

@class XMPPStream;

@interface FBService : NSObject
{
    NSTimer     *presenceTimer;
	XMPPStream	*xmppStream;
}
@property (nonatomic, strong) NSTimer *presenceTimer;
@property (strong, nonatomic) FBSession *session;
@property (assign, nonatomic) BOOL isInChatRoom;

+ (instancetype)shared;

#pragma mark -
#pragma mark Facebook Requests

- (void) userProfileWithResultBlock:(FBResultBlock)resultBlock;
- (void) userFriendsUsingBlock:(FBResultBlock)resultBlock;
- (void) userProfileWithID:(NSString *)userID withBlock:(FBResultBlock)resultBlock;


#pragma mark -
#pragma mark Messages

- (void)sendMessage:(NSString *)messageText toUserWithID:(NSString *)userID;


#pragma mark -
#pragma mark Options

+ (NSMutableDictionary *)findFBConversationWithFriend:(NSMutableDictionary *)aFriend;


#pragma mark -
#pragma mark XMPP Chat

- (void) logInChat;
- (void) logOutChat;
- (void) sendMessage:(NSString*)textMessage toFacebookWithFriendID:(NSString*)friendID;
- (void) inboxMessagesWithBlock:(FBResultBlock)resultBlock;

@end
