//
//  QBBS3PostAnswer.h
//  Mobserv
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBBS3PostAnswer : QBBS3Answer {
	NSURL* location;
	NSString* bucket;
	NSString* key;
	NSString* eTag;
}
@property (nonatomic,retain) NSURL* location;
@property (nonatomic,retain) NSString* bucket;
@property (nonatomic,retain) NSString* key;
@property (nonatomic,retain) NSString* eTag;
@end
