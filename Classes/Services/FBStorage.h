//
//  DataManager.h
//  ChattAR for Facebook
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
@property (nonatomic, strong) NSMutableArray        *otherUsers;
@property (nonatomic, strong) NSMutableDictionary   *allFriendsHistoryConversation;

+ (instancetype)shared;


#pragma mark -
#pragma mark FB

- (void) saveFBToken:(NSString *)token;
- (void)clearFBAccess;
- (NSDictionary *) fbUserToken;
- (void)clearFBUser;


#pragma mark -
#pragma mark Some Options

- (BOOL)isFacebookFriend:(NSMutableDictionary *)user;
- (NSMutableDictionary *)findUserWithMessage:(QBChatMessage *)message;


@end
