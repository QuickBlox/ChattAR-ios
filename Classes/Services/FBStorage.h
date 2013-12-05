//
//  FBStorage.h
//  ChattAR
//
//  Created by QuickBlox developers on 04.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBStorage : NSObject

// FB access
@property (nonatomic, strong) NSString				*accessToken;
@property (nonatomic, strong) NSMutableDictionary	*me;
@property (nonatomic, strong) NSMutableArray        *friends;
@property (nonatomic, strong) NSMutableDictionary   *allFriendsHistoryConversation;

+ (instancetype)shared;


#pragma mark -
#pragma mark Some Options

- (BOOL)isFacebookFriend:(NSMutableDictionary *)user;
- (BOOL)isFacebookFriendWithID:(NSString *)ID;
- (NSMutableDictionary *)findUserWithMessage:(QBChatMessage *)message;


@end
