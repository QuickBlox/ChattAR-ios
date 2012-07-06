//
//  FBService.h
//  FB_Radar
//
//  Created by Sonny Black on 07.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FBConnect.h"
#import "FBServiceResultDelegate.h"


@class XMPPStream;

@interface FBService : NSObject <FBRequestDelegate>
{
	XMPPStream	*xmppStream;
	
	BOOL		allowSelfSignedCertificates;
	BOOL		allowSSLHostNameMismatch;
	
	NSTimer		*presenceTimer;
}
@property (nonatomic, assign) Facebook	*facebook;
@property (nonatomic, assign) BOOL		isChatDidConnect;

+ (FBService *)shared;


#pragma mark -
#pragma mark Me

- (void) userProfileWithDelegate:(NSObject <FBServiceResultDelegate> *)delegate;


#pragma mark -
#pragma mark Users

- (void) usersProfilesWithIds:(NSString*)ids delegate:(NSObject <FBServiceResultDelegate>*)delegate context:(id)context;


#pragma mark -
#pragma mark Friends

- (void) friendsGetWithDelegate:(NSObject <FBServiceResultDelegate>*)delegate;
- (void) friendsCheckinsWithDelegate:(NSObject <FBServiceResultDelegate>*)delegate;


#pragma mark -
#pragma mark Messages & Chat

- (void) logInChat;
- (void) logOutChat;
- (void) inboxMessagesWithDelegate:(NSObject <FBServiceResultDelegate>*)delegate;
- (void) sendMessageToFacebook:(NSString*)textMessage withFriendFacebookID:(NSString*)friendID;

@end
