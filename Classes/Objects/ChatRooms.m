//
//  ChatRooms.m
//  ChattAR
//
//  Created by Igor Alefirenko on 30/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "ChatRooms.h"

@implementation ChatRooms
@synthesize currentPath = _currentPath;

   static ChatRooms *defaultChatRoom = nil;
+ (ChatRooms *)action{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultChatRoom = [[self alloc] init];
    });
    return defaultChatRoom;
    
}

- (id)init{
    self = [super init];
    if (self) {
        self.allTrendingRooms = [[NSArray alloc] init];
        self.allLocalRooms = [[NSArray alloc] init];
    }
    return self;
}


#pragma mark - 
#pragma mark Setter & Getter

-(void)setTrendingRooms:(NSArray *)rooms{
    self.allTrendingRooms = rooms;
}

-(void)setLocalRooms:(NSArray *)rooms{
    self.allLocalRooms = rooms;
}

-(NSArray *)getTrendingRooms{
    return self.allTrendingRooms;
}

-(NSArray *)getLocalRooms{
    return self.allLocalRooms;
}

@end
