//
//  BlobResult.h
//  BlobsService
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBBlobResult : Result {
@protected
	QBBlob* blob;
}

/** File info */
@property (nonatomic,readonly) QBBlob* blob;

@end
