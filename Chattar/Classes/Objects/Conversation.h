//
//  Conversation.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 6/15/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Conversation : NSObject

@property (nonatomic, retain) NSDictionary *to;
@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, assign) BOOL isUnRead;

@end
