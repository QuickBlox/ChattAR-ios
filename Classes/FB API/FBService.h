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
	
	BOOL		allowSelfSignedCertificates;
	BOOL		allowSSLHostNameMismatch;
	
	NSTimer		*presenceTimer;
}
@property (nonatomic, strong) NSString *fbToken;
@property (strong, nonatomic) FBSession *session;
+ (FBService *)shared;



#pragma mark -
#pragma mark Messages & Chat

- (void) logInChat;
- (void) logOutChat;


@end
