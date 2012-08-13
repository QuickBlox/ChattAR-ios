//
//  QBMSendPushTask.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

@interface QBMSendPushTask : Task {
	NSString *usersIDs;
	QBMPushMessage *pushMessage;
    BOOL isEnvironmentDevelopment;
}
@property (nonatomic, retain) NSString *usersIDs;
@property (nonatomic, retain) QBMPushMessage *pushMessage;
@property (nonatomic) BOOL isDevelopmentEnvironment;

@end
