//
//  NumberToLetterConverter.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 04.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NumberToLetterConverter : NSObject
{
    NSArray *numbersToLettersMap;
}

+ (NumberToLetterConverter *)instance;
- (NSString *) convertNumbersToLetters:(NSString *) number;



@end
