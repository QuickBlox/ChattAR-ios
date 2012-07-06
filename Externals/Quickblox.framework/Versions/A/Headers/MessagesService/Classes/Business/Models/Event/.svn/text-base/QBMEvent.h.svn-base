//
//  QBMEvent.h
//  MessagesService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

/** QBMEvent class declaration. */
/** Overview */
/** Event representation. If you want to send Apple push - use concrete subsclasses QBMPushEvent. */

@interface QBMEvent : Entity {
    BOOL active;
    enum QBMNotificationType notificationType;
    
    NSString *usersIDs;
    NSArray *usersTagsAny;
    NSArray *usersTagsAll;
    NSArray *usersTagsExclude;
    
    NSString *name;
    
    BOOL isEnvironmentDevelopment;
    NSMutableDictionary *message;
    QBMEventType type;
}

/** Event state. If you want to send specific notification more than once - just edit Event & set this field to 'YES', Then push will be send immediately, without creating a new one Event. */
@property (nonatomic) BOOL active;

/** Notification type*/
@property (nonatomic) QBMNotificationType notificationType;

/** Recipients - should contain a string of user ids divided by comas.*/
@property (nonatomic,retain) NSString *usersIDs;

/** Recipients tags. Recipients (users) must have at LEAST ONE tag that specified in list.*/
@property (nonatomic,retain) NSArray *usersTagsAny;

/** Recipients tags. Recipients (users) must exactly have ONLY ALL tags that specified in list. */
@property (nonatomic,retain) NSArray *usersTagsAll;

/** Recipients tags. Recipients (users) mustn't have tags that specified in list. */
@property (nonatomic,retain) NSArray *usersTagsExclude;

/** The name of the event. Service information. Only for the user..*/
@property (nonatomic,retain) NSString *name;

/** Environment of the notification */
@property (nonatomic) BOOL isEnvironmentDevelopment;

/** Event message */
@property (nonatomic,retain) NSMutableDictionary *message;

/** Event type */
@property (nonatomic) QBMEventType type;


- (void)prepareMessage;


#pragma mark -
#pragma mark Converters

+ (enum QBMEventType)eventTypeFromString:(NSString*)eventType;
+ (NSString*)eventTypeToString:(enum QBMEventType)eventType;

+ (NSString*)messageToString:(NSDictionary*)message;
+ (NSDictionary*)messageFromString:(NSString*)message;

@end
