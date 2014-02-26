//
//  QBStorage.h
//  ChattAR
//
//  Created by Igor Alefirenko on 15/11/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBStorage : NSObject

@property (nonatomic, strong) NSMutableArray        *chatHistory;
@property (nonatomic, strong) NSMutableDictionary   *allQuickBloxHistoryConversation;
@property (nonatomic, strong) QBChatRoom            *joinedChatRoom;
@property (nonatomic, strong) QBUUser               *me;
@property (nonatomic, strong) NSMutableArray        *otherUsers;
@property (nonatomic, strong) NSMutableDictionary   *otherUsersAsDictionary;
@property (nonatomic, copy)   NSString              *chatRoomName;
@property (nonatomic, strong) NSDictionary          *pushNotification;

+ (instancetype)shared;


#pragma mark -
#pragma mark Cache

- (void)saveHistory;
- (void)loadHistory;

@end
