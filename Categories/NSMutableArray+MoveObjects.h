//
//  NSMutableArray+MoveObjects.h
//  ChattAR
//
//  Created by Igor Alefirenko on 14/01/2014.
//  Copyright (c) 2014 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (MoveObjects)

- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
