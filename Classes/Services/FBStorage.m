//
//  FBStorage.m
//  ChattAR
//
//  Created by QuickBlox developers on 04.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "FBStorage.h"
#import "QBService.h"
#import "QBStorage.h"

@implementation FBStorage

@synthesize accessToken;
@synthesize me;

+ (instancetype)shared {
    static id defaultFBStorageInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultFBStorageInstance = [[self alloc] init];
    });
    return defaultFBStorageInstance;
}

- (id)init {
    if (self = [super init]) {
        self.allFriendsHistoryConversation = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setFriends:(NSMutableArray *)friends{
    _friends = friends;
    
    // make friends as dictionary
    self.friendsAsDictionary = [NSMutableDictionary dictionary];
    for(NSMutableDictionary *friend in friends){
        [self.friendsAsDictionary setObject:friend forKey:friend[kId]];
    }
}


#pragma mark -
#pragma mark FB access

- (void)setAccessToken:(NSString *)__accessToken{
    accessToken = __accessToken;
    if(accessToken == nil){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:FBAccessTokenKey];
        [defaults synchronize];
    }else{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:accessToken forKey:FBAccessTokenKey];
        [defaults synchronize];
    }
}


#pragma mark -
#pragma mark Some Options

- (NSMutableDictionary *)findUserWithMessage:(QBChatMessage *)message
{
    NSMutableDictionary *messageData = [[QBService defaultService] unarchiveMessageData:message.text];
    NSString *senderID = messageData[kId];
    // find friend
    NSMutableDictionary *user = self.friendsAsDictionary[senderID];
    if (user != nil) {
        return user;
    }
    // if friend == nil, find other user
    user = [QBStorage shared].otherUsersAsDictionary[senderID];
    return user;
}

- (BOOL)isFacebookFriend:(NSMutableDictionary *)user {
    return [user[kIsFriend] boolValue];
}

- (BOOL)isFacebookFriendWithID:(NSString *)ID {
    NSMutableDictionary *user = self.friendsAsDictionary[ID];
    if (user != nil) {
        return YES;
    }
    return NO;
}

@end
