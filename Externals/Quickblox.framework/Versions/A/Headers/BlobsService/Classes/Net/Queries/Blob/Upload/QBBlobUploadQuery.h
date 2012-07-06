//
//  QBBlobUploadQuery.h
//  Mobserv
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBBlobUploadQuery : QBBlobQuery {
	QBBlobObjectAccess* writeAccess;
	NSString* filePath;
	NSData* fileData;
}
@property (nonatomic,retain) QBBlobObjectAccess* writeAccess;
@property (nonatomic,retain) NSString* filePath;
@property (nonatomic,retain) NSData* fileData;
- (id)initWithObjectWriteAccess:(QBBlobObjectAccess*)writeAccess blob:(QBBlob*)blob;
@end
