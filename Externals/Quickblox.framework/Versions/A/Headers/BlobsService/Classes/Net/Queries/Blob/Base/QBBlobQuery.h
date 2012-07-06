//
//  BlobQuery.h
//  BlobsService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBBlobQuery : QBBlobsServiceQuery {
@protected
	QBBlob *blob;
}

@property (nonatomic,readonly) QBBlob *blob;

-(id)initWithBlobData:(QBBlob *)blobData;

@end