//
//  Conversation.h
//  FB_Radar
//
//  Created by Igor Khomenko on 6/15/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Conversation : NSObject

@property (nonatomic, retain) NSDictionary *to;
@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, assign) BOOL isUnRead;

@end
