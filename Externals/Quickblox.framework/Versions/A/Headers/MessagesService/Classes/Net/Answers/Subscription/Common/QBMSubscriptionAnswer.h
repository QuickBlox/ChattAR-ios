//
//  QBMSubscriptionAnswer.h
//  MessagesService
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

@interface QBMSubscriptionAnswer : QBMessagesServiceAnswer {
}

@property (nonatomic, retain) NSMutableArray *subscriptions;
@property (nonatomic, assign) QBMSubscription *currentItem;

@property (nonatomic, retain) NSString *prevElementName;

@end
