//
//  QBRAveragePagedAnswer.h
//  Quickblox
//
//  Created by Alexander Chaika on 05.04.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBRAveragePagedAnswer : QBRatingsServicePagedAnswer{
	QBRAverage *currentItem;
	NSMutableArray *averages;
}

@property (nonatomic, retain) NSMutableArray *averages;
@property (nonatomic, assign) QBRAverage *currentItem;

@end
