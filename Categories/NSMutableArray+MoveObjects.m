//
//  NSMutableArray+MoveObjects.m
//  ChattAR
//
//  Created by Igor Alefirenko on 14/01/2014.
//  Copyright (c) 2014 Stefano Antonelli. All rights reserved.
//

#import "NSMutableArray+MoveObjects.h"

@implementation NSMutableArray (MoveObjects)

- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    id object = [self objectAtIndex:fromIndex];
    [self removeObjectAtIndex:fromIndex];
    [self insertObject:object atIndex:toIndex];
}

@end
