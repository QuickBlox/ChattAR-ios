//
//  BlobGetQuery.h
//  BlobsService
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBBlobGetQuery : QBBlobQuery {
@private
	NSString* UID;

}
@property (nonatomic,readonly) NSString* UID;

-(id)initWithBlobUID:(NSString*)blobUID;
@end
