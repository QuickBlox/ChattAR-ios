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
@property (strong, nonatomic) NSString *roomName;
@property (strong, nonatomic) NSString *roomID;

+ (FBService *)shared;

#pragma mark -
#pragma mark Me

- (void) userProfileWithResultBlock:(FBResultBlock)resultBlock;
- (void) userProfileWithID:(NSString *)userID withBlock:(FBResultBlock)resultBlock;

#pragma mark -
#pragma mark Messages & Chat

- (void) logInChat;
- (void) logOutChat;


@end
