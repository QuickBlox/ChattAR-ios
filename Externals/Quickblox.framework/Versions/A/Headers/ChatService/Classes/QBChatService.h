//
//  QBChatService.h
//  QBChatService
//

//  Copyright 2012 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QBChatServiceDelegate.h"
#import "QBChatMessage.h"
#import "QBChatRoom.h"

/**
 QBChatServiceError enum defines following connection error codes:
 QBChatServiceErrorConnectionRefused - Connection with server is not available
 QBChatServiceErrorConnectionClosed  - Chat service suddenly became unavailable
 QBChatServiceErrorConnectionTimeout - Connection with server timed out
 */
typedef enum QBChatServiceError {
    QBChatServiceErrorConnectionRefused,
    QBChatServiceErrorConnectionClosed,
    QBChatServiceErrorConnectionTimeout
} QBChatServiceError;

@interface QBChatService : NSObject{
@private
    id<QBChatServiceDelegate> delegate;
}

/**
 Get QBChatService singleton
 
 @return QBChatService Chat service singleton
 */
+ (QBChatService *)instance;

/**
 Authorize on QBChatService
 
 @param user QBUUser structure represents users login
 @return NO if user was logged in before method call, YES if user was not logged in
 */
- (BOOL)login;

/**
 Check if current user logged into QBChatService
 
 @return YES if user is logged in, NO otherwise
 */
- (BOOL)isLoggedIn;

/**
 Logout current user from QBChatService
 
 @return YES if user was logged in before method call, NO if user was not logged in
 */
- (BOOL)logout;

/**
 Send message
 
 @param message QBChatMessage structure which contains message text and recipient id
 @return YES if user was logged in before method call, NO if user was not logged in
 */
- (BOOL)sendMessage:(QBChatMessage *)message;

/**
 Create instance of XMPPRoom class
 */
- (QBChatRoom*)newRoomWithName:(NSString*)name;

/**
 Join previously created room
 */
- (void)joinRoom:(QBChatRoom*)room;

/**
 Leave joined room
 */
- (void)leaveRoom:(QBChatRoom*)room;

/**
 Send message to current room
 */
- (void)sendMessage:(NSString *)msg toRoom:(QBChatRoom*)room;

/**
 Send presence message to Chat server. Session will be closed in 90 seconds since last activity.
 */
- (void)sendPresence;

/**
 Send request for getting list of public groups
 */
- (void)requestAllRooms;

/**
 Send request for getting list of room members
 */
- (void)requestListOfMembersRoom:(QBChatRoom*)room;

/**
 Send request to adding users with jids array to room. Responce call (void)didReceiveListOfUsers:(NSArray *)users; delegate method.
 */
- (void)addUsers:(NSArray*)jids toRoom:(QBChatRoom*)room;

/**
 Send request to remove users with jids array from room. Responce call (void)didReceiveListOfUsers:(NSArray *)users; delegate method.
 */
- (void)deleteUsers:(NSArray*)jids fromRoom:(QBChatRoom*)room;

/**
 Send request to remove user for getting presence status.
 */
- (void)requestUserForPresence:(NSString*)jid;

/**
 Retrieve JID from QBUUser
 */
- (NSString *)jidFromUser:(QBUUser *)user;

/**
 QBChatService delegate for callbacks
 */
@property (nonatomic, retain) id<QBChatServiceDelegate> delegate;

@end
