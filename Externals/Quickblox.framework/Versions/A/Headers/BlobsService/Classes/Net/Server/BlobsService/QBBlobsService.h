//
//  BlobsService.h
//  BlobsService
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBBlobsService : BaseService {
    
}
/** QBBlobsService class declaration. */

/** Overview: This class is the main entry point to work with cloud stored files, blobs. */

/** @name Uploading file */

/** Use this method to upload new files synchronously.
 @param blob An instance of QBBlob, describing the file to be uploaded.
 @return An instance of QBBlobResult, which contains operation status and updated instance of QBBlob.
 */ 
+ (QBBlobCreateResult*)CreateBlob:(QBBlob*)blob;

/** 
 Use this method to upload new files asynchronously. 
 @param blob An instance of QBBlob, describing the file to be uploaded.
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained.  Upon finish of the request, result will be an instance of QBBlobResult class.    
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable>*)CreateBlobAsync:(QBBlob*)blob delegate:(NSObject<ActionStatusDelegate>*)delegate;

/**
 Upload local file synchronously
 @param filePath path to local file
 @param blobOwnerID ID of blob owner
 @return An instance of QBUploadFileTaskResult, which contains operation status and an instance of QBBlob, uploaded file.
 */
+ (QBUploadFileTaskResult*)TUploadFile:(NSString*)filePath ownerID:(NSUInteger)blobOwnerID;

/**
 Upload local file asynchronously
 @param filePath path to local file
 @param blobOwnerID ID of blob owner
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained.  Upon finish of the request, result will be an instance of QBUploadFileTaskResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*)TUploadFileAsync:(NSString*)filePath ownerID:(NSUInteger)blobOwnerID delegate:(NSObject<ActionStatusDelegate>*)delegate;

/**
 Upload data synchronously
 @param fileData data to be uploaded
 @param blobOwnerID ID of blob owner
 @param fileName name of the file
 @param contentType type of the content in mime format
 @return An instance of QBUploadFileTaskResult, which contains operation status and an instance of QBBlob, uploaded file.
 */

+ (QBUploadFileTaskResult*)TUploadData:(NSData*)fileData 
                               ownerID:(NSUInteger)blobOwnerID
                              fileName:(NSString*)fileName
                           contentType:(NSString*)contentType;
/**
 Upload data asynchronously
 @param fileData data to be uploaded
 @param blobOwnerID ID of blob owner
 @param fileName name of the file
 @param contentType type of the content in mime format
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained.  Upon finish of the request, result will be an instance of QBUploadFileTaskResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*)TUploadDataAsync:(NSData*)fileData
								  ownerID:(NSUInteger)blobOwnerID
								 fileName:(NSString*)fileName
							  contentType:(NSString*)contentType
								 delegate:(NSObject<ActionStatusDelegate>*)delegate;


/** @name Downloading file */

/** Use this method to download file from server synchronously
 @param blobUID UID of the blob file to be obtained
 @return An instance of QBBlobFileResult, which contains operation status and file data.
 */
+ (QBBlobFileResult*)GetBlob:(NSString*)blobUID;

/** Use this method to download file from server asynchronously
 @param blobUID UID of the blob file to be obtained
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained. Upon finish of the request, result will be an instance of QBBlobFileResult class.
 */
+ (NSObject<Cancelable>*)GetBlobAsync:(NSString*)blobUID delegate:(NSObject<ActionStatusDelegate>*)delegate;

/** @name Getting file info*/

/** Use this method to get information of the existing file synchronously.
 
 @param blobId Unique blob identifier, value of ID property of the QBBlob instance.
 @return An instance of QBBlobResult, which contains operation status and instance of QBBlob.
 */ 
+ (QBBlobResult*)GetBlobInfo:(NSUInteger)blobID;

/** Use this method get information of the existing file asynchronously.
 
 @param blobId Unique blob identifier, value of ID property of the QBBlob instance.
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained. Upon finish of the request, result will be an instance of QBBlobResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */ 
+ (NSObject<Cancelable>*)GetBlobInfoAsync:(NSUInteger)blobID delegate:(NSObject<ActionStatusDelegate>*)delegate;

/** @name Updating file info */

/** Use this method to update existing file information synchronously.
 
 Normally, you first need to get blob from the server using GetBlobInfo: or GetBlobInfoAsync:delegate:, update neccessary fields and put it back to the server.
 @param blob An instance of QBBlob, describing the file to be updated.
 @return An instance of QBBlobResult, which contains operation status and updated instance of QBBlob.
 */ 
+ (QBBlobResult*)UpdateBlob:(QBBlob*)blob;

/** Use this method to update existing file information asynchronously.
 
 Normally, you first need to get blob information from the server using GetBlobInfo: or GetBlobInfoAsync:delegate: update neccessary fields and put it back to the server.  
 @param blob An instance of QBBlob, describing the file to be updated.
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained. Upon finish of the request, result will be an instance of QBBlobResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */ 
+ (NSObject<Cancelable>*)UpdateBlobAsync:(QBBlob*)blob delegate:(NSObject<ActionStatusDelegate>*)delegate;

/** @name Deleting file */

/** Use this method to delete existing file synchronously.
 
 @param blob An instance of QBBlob describing the file to be deleted.
 @return An instance of Result, which contains operation status.
 */
+ (Result*)DeleteBlob:(NSUInteger)blobID;

/** Use this method to delete existing file asynchronously.
 
 @param blob An instance of QBBlob describing the file to be deleted.
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained. Upon finish of the request, result will be an instance of Result class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable>*)DeleteBlobAsync:(NSUInteger)blobID delegate:(NSObject<ActionStatusDelegate>*)delegate;




+ (NSObject<Cancelable>*)blobsWithPagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<ActionStatusDelegate>*)delegate;




+ (Result*)UploadData:(NSData*)data access:(QBBlobObjectAccess*)writeAccess inBlob:(QBBlob*)blob;
+ (Result*)UploadFile:(NSString*)path access:(QBBlobObjectAccess*)writeAccess inBlob:(QBBlob*)blob;

+ (NSObject<Cancelable>*)UploadDataAsync:(NSData*)data 
								  access:(QBBlobObjectAccess*)writeAccess 
								  inBlob:(QBBlob*)blob
								delegate:(NSObject<ActionStatusDelegate>*)delegate;

+ (NSObject<Cancelable>*)UploadFileAsync:(NSString*)path 
								  access:(QBBlobObjectAccess*)writeAccess 
								  inBlob:(QBBlob*)blob 
								delegate:(NSObject<ActionStatusDelegate>*)delegate;


+ (Result*)CompleteBlob:(QBBlob*)blob;
+ (NSObject<Cancelable>*)CompleteBlobAsync:(QBBlob*)blob delegate:(NSObject<ActionStatusDelegate>*)delegate;



@end
