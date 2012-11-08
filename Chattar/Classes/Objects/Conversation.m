//
//  Conversation.m
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 6/15/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "Conversation.h"

@implementation Conversation

@synthesize to, messages, isUnRead;

- (id)init
{
    self = [super init];
    if (self) {
        isUnRead = NO;
    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"to=%@\nmessages=%@\nisUnRead=%d", to, messages, isUnRead];
}

@end
