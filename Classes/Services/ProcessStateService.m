//
//  ProcessStateService.m
//  ChattAR
//
//  Created by Igor Alefirenko on 27/01/2014.
//  Copyright (c) 2014 Stefano Antonelli. All rights reserved.
//

#import "ProcessStateService.h"

@implementation ProcessStateService


+ (instancetype)shared
{
    static id processStateInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        processStateInstance = [[self alloc] init];
    });
    return processStateInstance;
}

- (BOOL)splashCanBeDismissed
{
    if (self.facebookFriendsLoaded && self.facebookUsersLoaded && self.chatLocalRoomsLoaded && self.chatTrengingRoomsLoaded) {
        return YES;
    }
    return NO;
}

@end
