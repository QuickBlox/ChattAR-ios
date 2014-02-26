//
//  NSString+Parsing.m
//  ChattAR
//
//  Created by Igor Alefirenko on 20/01/2014.
//  Copyright (c) 2014 Stefano Antonelli. All rights reserved.
//

#import "NSString+Parsing.h"

@implementation NSString (Parsing)


- (NSString *)firstNameFromNameField {
    NSRange range = [self rangeOfString:@" "];
    NSString *substring = [self substringToIndex:range.location];
    return substring;
}

- (NSString *)lastNameFromNameField {
    NSRange range = [self rangeOfString:@" "];
    NSString *substring = [self substringFromIndex:range.location+1];
    return substring;
}

@end
