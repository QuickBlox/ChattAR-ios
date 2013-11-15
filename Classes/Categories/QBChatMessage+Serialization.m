//
//  QBChatMessage+Serialization.m
//  ChattAR
//
//  Created by Igor Alefirenko on 13/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "QBChatMessage+Serialization.h"

@implementation QBChatMessage (Serialization)

- (NSString *)quickbloxUserID {
    NSRange range = [self.senderNick rangeOfString:@"_"];
    NSString *substring = [self.senderNick substringFromIndex:range.location+1];
    return substring;
}

- (NSString *)facebookUserID {
    NSRange range = [self.senderNick rangeOfString:@"_"];
    NSRange neededRange;
    neededRange.location = 0;
    neededRange.length = range.location;
    NSString *substring = [self.senderNick substringWithRange:neededRange];
    return substring;
}

@end
