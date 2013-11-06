//
//  ChatRooms.m
//  ChattAR
//
//  Created by Igor Alefirenko on 30/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "ChatRoomsService.h"

@implementation ChatRoomsService

+ (instancetype)shared {
    static ChatRoomsService *sharedChatRoomsService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedChatRoomsService = [[self alloc] init];
    });
    return sharedChatRoomsService;
}

#pragma mark - Sort

- (NSMutableArray *)sortingRoomsByDistance:(CLLocation *)me toChatRooms:(NSArray *)rooms {
    NSArray *sortedRooms = [rooms sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CLLocation *room1 = [[CLLocation alloc] initWithLatitude:[[[obj1 fields] objectForKey:kLatitude] doubleValue] longitude:[[[obj1 fields] objectForKey:kLongitude] doubleValue]];
        CLLocation *room2 = [[CLLocation alloc] initWithLatitude:[[[obj2 fields] objectForKey:kLatitude] doubleValue] longitude:[[[obj2 fields] objectForKey:kLongitude] doubleValue]];
        NSInteger distance1 = [me distanceFromLocation:room1];
        NSInteger distance2 = [me distanceFromLocation:room2];
        
        if ( distance1 < distance2) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ( distance1 > distance2) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
        
    }];
    NSMutableArray *neibRooms = [NSMutableArray array];
    for (int i=0; i<30; i++) {
        if ([sortedRooms objectAtIndex:i] != [sortedRooms lastObject]) {
            [neibRooms addObject:[sortedRooms objectAtIndex:i]];
        } else {
            [neibRooms addObject:[sortedRooms objectAtIndex:i]];
            break;
        }
    }
    return neibRooms;
}


@end
