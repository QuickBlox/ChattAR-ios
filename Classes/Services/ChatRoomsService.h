//
//  ChatRooms.h
//  ChattAR
//
//  Created by Igor Alefirenko on 30/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatRoomsService : NSObject

@property (nonatomic, strong) NSArray *allTrendingRooms;
@property (nonatomic, strong) NSArray *allLocalRooms;
@property (nonatomic, strong) NSMutableArray *distances;
@property (nonatomic, assign) BOOL endOfList;

+ (instancetype)shared;

@end
