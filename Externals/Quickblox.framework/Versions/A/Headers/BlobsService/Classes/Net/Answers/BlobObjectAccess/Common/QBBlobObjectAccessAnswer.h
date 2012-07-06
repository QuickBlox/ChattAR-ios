//
//  QBBlobObjectAccessAnswer.h
//  Mobserv
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBBlobObjectAccessAnswer : QBBlobsServiceAnswer {
	NSMutableString* paramsBuffer;
}
@property (nonatomic, retain) NSMutableString* paramsBuffer;
@property (nonatomic, readonly) QBBlobObjectAccess* blobObjectAccess;
@end
