//
//  QBStorage.m
//  ChattAR
//
//  Created by Igor Alefirenko on 15/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "QBStorage.h"

@implementation QBStorage

+ (instancetype)shared {
    static QBStorage *defaultQBStorage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultQBStorage = [[self alloc] init];
    });
    return defaultQBStorage;
}

- (id)init {
    if (self = [super init]) {
        self.chatHistory = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
