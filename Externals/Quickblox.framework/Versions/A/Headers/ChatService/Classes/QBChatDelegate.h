//
//  QBChatServiceDelegate.h
//  QBChatService
//

//  Copyright 2012 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QBChat.h"
#import "QBChatMessage.h"
#import "QBChatRoom.h"

/**
 QBChatServiceDelegate protocol definition
 This protocol defines methods signatures for callbacks. Implement this protocol in your class and
 set QBChatService.delegate to your implementation instance to receive callbacks from QBChatService
 */
@protocol QBChatDelegate <NSObject>

@optional
/**
 didLogin fired by QBChatService when connection to service established and login is successfull
 */
- (void)chatDidLogin;

/**
 didNotLogin fired when login process did not finished successfully
 */
- (void)chatDidNotLogin;

/**
 didNotSendMessage fired when message cannot be send to offline user
 
 @param message Message passed to sendMessage method into QBChatService
 */
- (void)chatDidNotSendMessage:(QBChatMessage *)message;

/**
 didReceiveMessage fired when new message was received from QBChatService
 
 @param message Message received from QBChatService
 */
- (void)chatDidReceiveMessage:(QBChatMessage *)message;

/**
 didFailWithError fired when connection error occurs
 
 @param error Error code from QBChatServiceError enum
 */
- (void)chatDidFailWithError:(int)error;

/**
 Fired when room was successfully created
 */
- (void)chatRoomDidCreated:(QBChatRoom*)room;

/**
 Called when room received message. It will be fired each time when room receiving message from any user
 */
- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoom:(QBChatRoom *)room;

/**
 Called in case changing occupant
 */
- (void)chatRoomDidChangeOccupants:(NSDictionary *)occupants room:(QBChatRoom *)room;

/**
 Called in case receiving list of avaible to join rooms. Array rooms contains jids NSString type
 */
- (void)chatDidReceiveListOfRooms:(NSArray *)rooms;

/**
 Called in case receiving list of occupants of chat room. Array users contains jids NSString type
 */
- (void)chatDidReceiveListOfUsers:(NSArray *)users;

/**
 Called in case receiving presence
 */
- (void)chatDidReceivePresenceOfUser:(NSUInteger)userID type:(NSString *)type;

@end
