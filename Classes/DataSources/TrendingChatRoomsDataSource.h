//
//  TrendingDataSource.h
//  ChattAR
//
//  Created by Igor Alefirenko on 09/09/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrendingChatRoomsDataSource : NSObject <UITableViewDataSource>

@property (strong, nonatomic) NSArray *chatRooms;

@end
