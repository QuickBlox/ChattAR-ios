//
//  QBService.h
//  ChattAR
//
//  Created by Igor Alefirenko on 25/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBService : NSObject <QBChatDelegate>

@property (nonatomic, assign) BOOL              *userIsJoinedChatRoom;
@property (nonatomic, strong) QBUUser           *me;
@property (nonatomic, strong) QBUUser           *qbFriend;
@property (nonatomic, strong) QBChatRoom        *currentChatRoom;
@property (nonatomic, strong) NSMutableArray    *dialogMessages;

+(instancetype)defaultService;

@end
