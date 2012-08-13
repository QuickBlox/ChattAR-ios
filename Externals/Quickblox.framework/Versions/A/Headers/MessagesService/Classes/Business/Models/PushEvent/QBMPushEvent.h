//
//  QBMPushEvent.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

/** QBMPushEvent class declaration. */
/** Overview */
/** Push event representation */

@interface QBMPushEvent : QBMEvent {
	QBMPushMessage *pushMessage;
}

/** Apple push message to send to subscribers */
@property (nonatomic,retain) QBMPushMessage *pushMessage;

/** Create new push event
 @return New instance of QBMPushEvent
 */
+ (QBMPushEvent *)pushEvent;

@end
