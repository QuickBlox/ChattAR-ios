//
//  BlobInfoQuery.h
//  BlobsService
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBBlobInfoQuery : QBBlobQuery {
@private
	NSUInteger blobId;
    PagedRequest *pagedRequest;
    
    BOOL isMultipleGet;
}
@property (nonatomic,readonly) NSUInteger blobId;
@property (nonatomic, readonly) PagedRequest *pagedRequest;

- (id)initWithBlobId:(NSUInteger)blobid;
- (id)initWithPagedRequest:(PagedRequest *)pagedRequest;

@end
