//
//  QBBFileUploadTask.h
//  Mobserv
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBBUploadFileTask : Task {
	NSString *filePath;
	NSData *fileData;
	NSString *contentType;
	NSString *fileName;
	QBBlob *blob;
	QBBlobObjectAccess *writeAccess;
	NSUInteger blobOwnerID;
}
@property (nonatomic,retain) NSString *filePath;
@property (nonatomic,retain) NSString *contentType;
@property (nonatomic,retain) NSString *fileName;
@property (nonatomic,retain) NSData *fileData;
@property (nonatomic,retain) QBBlob *blob;
@property (nonatomic,retain) QBBlobObjectAccess *writeAccess;
@property (nonatomic) NSUInteger blobOwnerID;

@end