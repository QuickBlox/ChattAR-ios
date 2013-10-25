//
//  QBService.m
//  ChattAR
//
//  Created by Igor Alefirenko on 25/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "QBService.h"

@implementation QBService

+(instancetype)defaultService{
    static QBService *defaultQBService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultQBService = [[self alloc] init];
    });
    return defaultQBService;
}

-(id)init{
    self = [super init];
    if (self) {
        self.userIsJoinedChatRoom = NO;
    }
    return self;
}

@end
