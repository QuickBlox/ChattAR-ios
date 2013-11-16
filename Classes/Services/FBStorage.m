//
//  DataManager.m
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 04.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "FBStorage.h"
#import "QBService.h"

@implementation FBStorage

@synthesize accessToken;
@synthesize friends;
@synthesize me;


+ (instancetype)shared {
    static FBStorage *defaultFBStorageInstance = nil;
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

#pragma mark -
#pragma mark FB access

- (void)saveFBToken:(NSString *)token {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:token forKey:FBAccessTokenKey];
	[defaults synchronize];
    
    accessToken = token;
}

- (void)clearFBAccess {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:FBAccessTokenKey];
	[defaults synchronize];

    accessToken = nil;
}

- (NSDictionary *)fbUserToken
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if ([defaults objectForKey:FBAccessTokenKey]){
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:[defaults objectForKey:FBAccessTokenKey] forKey:FBAccessTokenKey];        
		return dict;
    }
    
    return nil;
}


#pragma mark -
#pragma mark Some Options

- (NSMutableDictionary *)findUserWithMessage:(QBChatMessage *)message
{
    NSMutableDictionary *messageData = [[QBService defaultService] unarchiveMessageData:message.text];
    NSString *senderID = [messageData objectForKey:kId];
    // at first, searching in FBCache(as friend):
    NSMutableArray *facebookFriends = self.friends;
    NSMutableDictionary *currentUser;
    for (NSMutableDictionary *friend in facebookFriends) {
        if ([senderID isEqual:[friend objectForKey:kId]]) {
            currentUser = friend;
            return currentUser;
        }
    }
    // then search in QBCache:
    for (NSMutableDictionary *user in self.otherUsers) {
        if ([senderID isEqual:[user objectForKey:kId]]) {
            currentUser = user;
            break;
        }
    }
    return currentUser;
}

- (BOOL)isFacebookFriend:(NSMutableDictionary *)user {
    for (NSMutableDictionary *friend in self.friends) {
        if ([[user objectForKey:kId] isEqualToString:[friend objectForKey:kId]]) {
            return YES;
        }
    }
    return NO;
}

@end
