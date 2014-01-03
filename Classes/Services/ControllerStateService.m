//
//  ControllerStateService.m
//  ChattAR
//
//  Created by Igor Alefirenko on 02/01/2014.
//  Copyright (c) 2014 Stefano Antonelli. All rights reserved.
//

#import "ControllerStateService.h"
#import "QBStorage.h"

@implementation ControllerStateService


+ (instancetype)shared {
    static id stateInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stateInstance = [[self alloc] init];
    });
    return stateInstance;
}

@end
