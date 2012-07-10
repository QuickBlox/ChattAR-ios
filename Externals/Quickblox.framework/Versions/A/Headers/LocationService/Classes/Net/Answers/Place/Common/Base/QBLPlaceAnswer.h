//
//  QBLPlaceAnswer.h
//  LocationService
//
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBLPlaceAnswer : QBLocationServiceAnswer{
@protected
	QBLPlace *place;
}

@property (nonatomic, readonly) QBLPlace *place;

@end
