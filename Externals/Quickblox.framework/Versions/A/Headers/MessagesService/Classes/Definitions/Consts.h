/*
 *  Consts.h
 *  MessagesService
 *

 *  Copyright 2011 QuickBlox team. All rights reserved.
 *
 */

extern NSString* const kMessagesServiceException;
extern NSString* const kMessagesServiceErrorDomain;

extern NSString* const kMessagesServiceErrorGetTokenTimeout;

extern NSString* const QBMEventMessagePayloadKey;

extern NSString* const QBMEventMessagePushAlertKey;
extern NSString* const QBMEventMessagePushBadgeKey;
extern NSString* const QBMEventMessagePushSoundKey;


// Push message dict keys
extern NSString* const QBMPushMessageAdditionalInfoKey;
extern NSString* const QBMPushMessageApsKey;
extern NSString* const QBMPushMessageAlertKey;
extern NSString* const QBMPushMessageAlertBodyKey;
extern NSString* const QBMPushMessageAlertActionLocKey;
extern NSString* const QBMPushMessageAlertLocKey;
extern NSString* const QBMPushMessageAlertLocArgsKey;
extern NSString* const QBMPushMessageAlertLaunchImageKey;
extern NSString* const QBMPushMessageBadgeKey;
extern NSString* const QBMPushMessageSoundKey;

// Event types
extern NSString *const kQBMEventTypeOneShot;
extern NSString *const kQBMEventTypeFixedDate;
extern NSString *const kQBMEventTypePeriodDate;
extern NSString *const kQBMEventTypeMultiShot;

// Notification channels
extern NSString *const kQBMNotificationChannelsEmail;
extern NSString *const kQBMNotificationChannelsAPNS;
extern NSString *const kQBMNotificationChannelsC2DM;
extern NSString *const kQBMNotificationChannelsMPNS;
extern NSString *const kQBMNotificationChannelsBBPS;
extern NSString *const kQBMNotificationChannelsPull;
extern NSString *const kQBMNotificationChannelsHttpRequest;
