//
//  QBStorage.h
//  ChattAR
//
//  Created by Igor Alefirenko on 15/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBStorage : NSObject

@property (nonatomic, strong) NSMutableArray        *chatHistory;
@property (nonatomic, strong) NSMutableDictionary   *allQuickBloxHistoryConversation;
@property (nonatomic, strong) QBChatRoom            *currentChatRoom;
@property (nonatomic, strong) QBUUser               *me;
@property (nonatomic, strong) NSMutableArray        *otherUsers;
@property (nonatomic, strong) NSString              *chatRoomName;

+ (instancetype)shared;


#pragma mark -
#pragma mark Cache

- (void)saveHistory;
- (void)loadHistory;

@end
