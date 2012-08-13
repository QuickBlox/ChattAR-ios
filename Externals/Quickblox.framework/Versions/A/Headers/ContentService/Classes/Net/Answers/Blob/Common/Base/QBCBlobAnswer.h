//
//  BlobAnswer.h
//  ContentService
//
//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBCBlobAnswer : QBContentServiceAnswer {
@protected
	QBCBlob* blob;
    QBCBlobObjectAccessAnswer* blobObjectAccessAnswer;
}

@property (nonatomic, readonly) QBCBlob* blob;
@property (nonatomic, retain) QBCBlobObjectAccessAnswer* blobObjectAccessAnswer;

@end
