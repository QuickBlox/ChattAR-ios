//
//  QBMPushTokenResult.h
//  MessagesService
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

@interface QBMPushTokenResult : QBMessagesServiceResult {

}

/** Push token */
@property (nonatomic,readonly) QBMPushToken *pushToken;

@end
