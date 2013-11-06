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
	XMPPStream	*xmppStream;
	NSTimer		*presenceTimer;
}
@property (strong, nonatomic) FBSession *session;
@property (assign, nonatomic) BOOL isInChatRoom;

+ (instancetype)shared;

#pragma mark -
#pragma mark Me

- (void) userProfileWithResultBlock:(FBResultBlock)resultBlock;
- (void) userFriendsUsingBlock:(FBResultBlock)resultBlock;
- (void) userProfileWithID:(NSString *)userID withBlock:(FBResultBlock)resultBlock;

#pragma mark -
#pragma mark Messages & Chat

- (void) logInChat;
- (void) logOutChat;
- (void) sendMessage:(NSString*)textMessage toFacebookWithFriendID:(NSString*)friendID;
- (void) inboxMessagesWithBlock:(FBResultBlock)resultBlock;

@end
