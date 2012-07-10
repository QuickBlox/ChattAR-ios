//
//  QBMSendPushTask.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

@interface QBMSendPushTask : Task {
	NSString *usersIDs;
	QBMPushMessage *pushMessage;
	QBMPushEvent *event;
    BOOL isEnvironmentDevelopment;
}
@property (nonatomic, retain) NSString *usersIDs;
@property (nonatomic, retain) QBMPushMessage *pushMessage;
@property (nonatomic, retain) QBMPushEvent *event;
@property (nonatomic) BOOL isEnvironmentDevelopment;

@end
