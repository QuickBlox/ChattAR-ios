//
//  FBChatService.m
//  ChattAR
//
//  Created by Igor Alefirenko on 04/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "FBChatService.h"
#import "FBService.h"
#import "FBStorage.h"
#import "Utilites.h"

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
    
    NSArray *users = [[FBChatService defaultService].allFriendsHistoryConversation allValues];
    for (NSMutableDictionary *user in users) {
        NSArray *to = [[user objectForKey:kTo] objectForKey:kData];
        for (NSDictionary *t in to) {
            if ([[t objectForKey:kId] isEqual:[aFriend objectForKey:kId]]) {
                return user;
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
    return newConversation;
}


#pragma mark -
#pragma mark Messaging

- (void)sendMessage:(NSString *)messageText toUserWithID:(NSString *)userID {
    // send message to facebook:
    [[FBService shared] sendMessage:messageText toFacebookWithFriendID:userID];
    
    // create message object
    NSMutableDictionary *facebookMessage = [[NSMutableDictionary alloc] init];
    [facebookMessage setValue:messageText forKey:kMessage];
    NSDate *date = [NSDate date];
    [[Utilites shared].dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
    NSString *createdTime = [[Utilites shared].dateFormatter stringFromDate:date];
    [facebookMessage setValue:createdTime forKey:kCreatedTime];
    [[Utilites shared].dateFormatter setDateFormat:@"HH:mm"];
    NSMutableDictionary *from = [[NSMutableDictionary alloc] init];
    [from setValue:[[FBStorage shared].me objectForKey:kId] forKey:kId];
    [from setValue:[[FBStorage shared].me objectForKey:kName] forKey:kName];
    [facebookMessage setValue:from forKey:kFrom];
    
    // save message to history
    NSMutableDictionary *conversation = [self.allFriendsHistoryConversation objectForKey:userID];
    NSMutableArray *data = [[conversation objectForKey:kComments] objectForKey:kData];
    if (data ==nil) {
        data = [[NSMutableArray alloc] initWithObjects:@[facebookMessage], nil];
        NSMutableDictionary *comments = [[NSMutableDictionary alloc] initWithObjects:@[data] forKeys:@[kData]];
        [conversation setObject:comments forKey:kComments];
    }
    [data addObject:facebookMessage];
    [[FBChatService defaultService].allFriendsHistoryConversation setObject:conversation forKey:userID];
    [[NSNotificationCenter defaultCenter] postNotificationName:CAChatDidReceiveOrSendMessageNotification object:nil];
}

@end
