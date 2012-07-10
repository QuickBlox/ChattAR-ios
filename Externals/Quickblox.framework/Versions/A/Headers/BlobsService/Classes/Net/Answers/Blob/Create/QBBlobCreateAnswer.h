//
//  BLBlobCreateAnswer.h
//  BlobsService
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBBlobCreateAnswer : QBBlobAnswer {
	QBBlobObjectAccessAnswer* blobObjectAccessAnswer;
}
@property (nonatomic,retain) QBBlobObjectAccessAnswer* blobObjectAccessAnswer;
@end
