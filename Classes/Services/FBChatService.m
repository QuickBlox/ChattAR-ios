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
        self.allFriendsHistoryConversation = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (NSMutableDictionary *)findFBConversationWithFriend:(NSMutableDictionary *)aFriend {
    NSMutableDictionary *conversation = [[NSMutableDictionary alloc] init];
    NSArray *users = [[FBChatService defaultService].allFriendsHistoryConversation allValues];
    for (NSMutableDictionary *user in users) {
        NSArray *to = [[user objectForKey:kTo] objectForKey:kData];
        for (NSDictionary *t in to) {
            if ([[t objectForKey:kId] isEqual:[aFriend objectForKey:kId]]) {
                conversation = user;
                return conversation;
            }
        }
    }
    // if not return, create new conversation:
    NSMutableDictionary *newConversation = [[NSMutableDictionary alloc]init];
    // adding commnets to this conversation:
    NSMutableDictionary *comments = [[NSMutableDictionary alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [comments setObject:array forKey:kData];
    [newConversation setObject:comments forKey:kComments];
    
    // adding kTo:
    NSMutableDictionary *kto = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[aFriend objectForKey:kId] forKey:kId];
    [dict setValue:[aFriend objectForKey:kName] forKey:kName];
    
    [kto setValue:[NSMutableArray arrayWithObject:dict] forKey:kData];
    [newConversation setObject:kto forKey:kTo];
    conversation = newConversation;
    return conversation;
}

@end
