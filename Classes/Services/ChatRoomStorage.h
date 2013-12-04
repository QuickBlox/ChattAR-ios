//
//  ChatRooms.h
//  ChattAR
//
//  Created by Igor Alefirenko on 30/09/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatRoomStorage : NSObject <QBActionStatusDelegate>

@property (nonatomic, strong) NSArray *allTrendingRooms;
@property (nonatomic, strong) NSArray *allLocalRooms;
@property (nonatomic, strong) NSMutableArray *distances;
@property (nonatomic, strong) NSArray *searchedRooms;
@property (nonatomic, assign) BOOL endOfList;

+ (instancetype)shared;


#pragma mark -
#pragma mark Create room

- (void)createChatRoomWithName:(NSString *)name imageData:(NSData *)imageData;


#pragma mark -
#pragma mark Options

- (NSMutableArray *)sortingRoomsByDistance:(CLLocation *)me toChatRooms:(NSArray *)rooms;
- (void)increaseRankOfRoom:(QBCOCustomObject *)room;

@end
