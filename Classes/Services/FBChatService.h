//
//  FBChatService.h
//  ChattAR
//
//  Created by Igor Alefirenko on 04/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBChatService : NSObject

@property (nonatomic, strong) NSMutableDictionary *allFriendsHistoryConversation;

+ (instancetype)defaultService;

@end
