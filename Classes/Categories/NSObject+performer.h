//
//  NSObject+performer.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 07.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (performer)

- (void) performSelectorOnMainThread:(SEL)selector withObject:(id)arg1 withObject:(id)arg2 waitUntilDone:(BOOL)wait;

@end
