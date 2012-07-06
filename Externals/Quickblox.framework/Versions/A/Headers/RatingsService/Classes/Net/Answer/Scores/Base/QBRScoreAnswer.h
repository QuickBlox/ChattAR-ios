//
//  QBRScoreAnswer.h
//  RatingsService
//
//  Created by Alexander Chaika on 02.04.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBRScoreAnswer : QBRatingsServiceAnswer {
	QBRScore *scoreData;
}

@property (nonatomic, readonly) QBRScore *scoreData;

@end
