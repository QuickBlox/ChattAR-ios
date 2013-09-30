//
//  ChatRooms.m
//  ChattAR
//
//  Created by Igor Alefirenko on 30/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "ChatRooms.h"

@implementation ChatRooms
@synthesize allChatRooms = _allChatRooms;
@synthesize currentPath = _currentPath;


+ (ChatRooms *)action{
    static ChatRooms *defaultChatRoom = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultChatRoom = [[self alloc] init];
    });
    return defaultChatRoom;
    
}

- (id)init{
    self = [super init];
    if (self) {
        self.allChatRooms = [[NSArray alloc] init];
    }
    return self;
}


#pragma mark - 
#pragma mark Setter & Getter

-(void)setRooms:(NSArray *)rooms{
    self.allChatRooms = rooms;
}

-(NSArray *)getAllRooms{
    NSArray *chatRooms = self.allChatRooms;
    return chatRooms;
}

@end
