//
//  QBMSubscriptionAnswer.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

@interface QBMSubscriptionAnswer : QBMessagesServiceAnswer{
@protected 
    NSMutableArray *subscriptions;
}

@property (nonatomic, readonly) NSMutableArray *subscriptions;

@end

