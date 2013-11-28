//
//  ChatRoomDataSource.h
//  ChattAR
//
//  Created by Igor Alefirenko on 28/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatRoomDataSource : NSObject <UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *chatHistory;

@end
