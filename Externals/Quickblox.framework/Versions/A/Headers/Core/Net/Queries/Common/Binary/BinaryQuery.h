//
//  BinaryQuery.h
//  Mobserv
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BinaryQuery : Query {
	NSURL* URL;
}
@property (nonatomic,retain) NSURL* URL;
- (id)initWithURL:(NSURL*)url;
@end
