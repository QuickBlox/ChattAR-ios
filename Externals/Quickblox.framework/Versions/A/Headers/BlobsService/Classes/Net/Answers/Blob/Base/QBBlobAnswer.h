//
//  BlobAnswer.h
//  BlobsService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBBlobAnswer : QBBlobsServiceAnswer {
@protected
	QBBlob* blob;
}

@property (nonatomic, readonly) QBBlob* blob;

@end
