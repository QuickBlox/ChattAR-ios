//
//  QBChatMessage.h
//  QBChatService
//

//  Copyright 2012 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 QBChatMessage structure. Contains all needed field for peer-to-peer chat.
 Please set only text and recipient_id values since ID and sender_id
 are setted automatically by QBChatService
 */
@interface QBChatMessage : NSObject <NSCoding, NSCopying>{
@private
    NSUInteger ID;
    NSString *text;
    NSString *recipientJID;
    NSString *senderJID;
    NSDate *datetime;
}

/**
 Unique identifier of message (sequential number)
 */
@property (nonatomic, assign) NSUInteger ID;

/**
 Message text
 */
@property (nonatomic, retain) NSString *text;

/**
 Message receiver JID
 */
@property (nonatomic, retain) NSString *recipientJID;

/**
 Message sender JID
 */
@property (nonatomic, retain) NSString *senderJID;

/**
 Message datetime
 */
@property (nonatomic, retain) NSDate *datetime;

@end
