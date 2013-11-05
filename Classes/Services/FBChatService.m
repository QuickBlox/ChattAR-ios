//
//  FBChatService.m
//  ChattAR
//
//  Created by Igor Alefirenko on 04/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "FBChatService.h"

@implementation FBChatService

+ (instancetype)defaultService {
    static FBChatService *defaultFBChatService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultFBChatService = [[self alloc] init];
    });
    return defaultFBChatService;
}

- (id)init {
    if (self = [super init]) {
        self.allFriendsHistoryConversation = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
