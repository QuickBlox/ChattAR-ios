//
//  DetailProfileCell.m
//  ChattAR
//
//  Created by Igor Alefirenko on 06/12/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "DetailProfileCell.h"

@implementation DetailProfileCell


- (void)handleCellWithContent:(NSDictionary *)content {
    NSString *key = [[content allKeys] firstObject];
    self.keyField.text = [key stringByAppendingString:@":"];
    self.valueField.text = content[key];
}

@end
