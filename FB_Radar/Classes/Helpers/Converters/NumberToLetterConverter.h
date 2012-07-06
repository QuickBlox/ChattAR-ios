//
//  NumberToLetterConverter.h
//  FB_Radar
//
//  Created by Sonny Black on 04.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NumberToLetterConverter : NSObject
{
    NSArray *numbersToLettersMap;
}

+ (NumberToLetterConverter *)instance;
- (NSString *) convertNumbersToLetters:(NSString *) number;



@end
