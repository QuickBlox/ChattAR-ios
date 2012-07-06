//
//  QBChatRoom.h
//  Quickblox
//
//  Created by Alexey on 11.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBChatRoom : NSObject
{
    @private
	NSString* name;
    id xmppRoom;
}

/**
 Room name
 */
@property (readonly) NSString* name;

/**
 Init QBChatRoom instance with name
 
 @return QBChatRoom instance
 */
- (id)initWithRoomName:(NSString *)roomName;

/**
 Add users to current room. Array users contains jids addresses of NSString type
 */
- (void)addUsers:(NSArray *)users;

/**
 Delete users from current room. Array users contains jids addresses of NSString type
 */
- (void)deleteUsers:(NSArray *)users;

/**
 Send QBChatMessage instance to current room
 */
- (void)sendMessage:(QBChatMessage *)message;

/**
 Join current room
 */
- (void)joinRoom;

/**
 Leave current room
 */
- (void)leaveRoom;

/**
 Get nick name of current room's creator
 */
- (NSString*)getOwnersNick;

/**
 Get JID of current room
 */
- (NSString*)getRoomName;



// private methods (do not use them)
- (void)setXmppRoom:(id)room;
- (id)xmppRoom;


@end
