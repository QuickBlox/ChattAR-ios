//
//  ChatRooms.m
//  ChattAR
//
//  Created by Igor Alefirenko on 30/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "ChatRoomsService.h"

@implementation ChatRoomsService

+ (instancetype)shared{
    static ChatRoomsService *sharedChatRoomsService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedChatRoomsService = [[self alloc] init];
    });
    return sharedChatRoomsService;
}

@end
