//
//  ChatRooms.h
//  ChattAR
//
//  Created by Igor Alefirenko on 30/09/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatRoomStorage : NSObject <QBActionStatusDelegate>

@property (nonatomic, strong) NSArray *allLoadedRooms;
@property (nonatomic, strong) NSArray *trendingRooms;
@property (nonatomic, strong) NSArray *localRooms;
@property (nonatomic, strong) NSMutableArray *distances;
@property (nonatomic, strong) NSArray *searchedRooms;
@property (nonatomic, assign) BOOL endOfList;
@property (nonatomic, assign) NSInteger unreadMessages;

+ (instancetype)shared;


#pragma mark -
#pragma mark Create room

- (void)createChatRoomWithName:(NSString *)name imageData:(NSData *)imageData;


#pragma mark -
#pragma mark Options

- (NSMutableArray *)sortRooms:(NSArray *)rooms accordingToLocation:(CLLocation *)location limit:(NSUInteger)limit;
- (void)increaseRankOfRoom:(QBCOCustomObject *)room;
- (QBCOCustomObject *)findChatRoomWithName:(NSString *)roomName;
- (int)trackAllUnreadMessages;

@end
