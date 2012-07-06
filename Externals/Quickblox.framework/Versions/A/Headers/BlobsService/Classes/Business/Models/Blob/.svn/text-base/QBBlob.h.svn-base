//
//  Blob.h
//  BlobsService
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBBlobResult, QBBlobSearchRequest, QBBlobSearchResult, QBBlobFileResult;

/** QBBlob class declaration. */

/** Overview: This class provide methods to work with Blobs. */

/** Limitations: max size of file is 5368709120 bytes (5 GB). */

@interface QBBlob : Entity 
{
	NSUInteger ownerID;             /// id of the file's owner
	NSString* contentType;          /// mime type of content
	NSString* name;                 /// file's name
	NSArray* tags;                  /// key values
	NSData* data;
	enum QBBlobStatus status;       /// this is the status of blob
	NSString* extendedStatus;       /// extended information about the status (optional). Usually it uses with Locked status
	NSDate* completedAt;            /// Date
	NSUInteger size;                /// the size of the file in bytes
	NSString* UID;                  /// unique id of file in the system            
}

/** @name Uploading file */

/** 
 Use this method to upload new files synchronously.
 @param blob An instance of QBBlob, describing the file to be uploaded.
 @return An instance of QBBlobResult, which contains operation status and updated instance of QBBlob.
 */ 
+ (QBBlobResult*)CreateBlob:(QBBlob*)blob;


/** 
 Use this method to upload new files asynchronously. 
 @param blob An instance of QBBlob, describing the file to be uploaded.
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained.  Upon finish of the request, result will be an instance of QBBlobResult class.    
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable>*)CreateBlobAsync:(QBBlob*)blob delegate:(NSObject<ActionStatusDelegate>*)delegate;

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
+ (QBBlobResult*)GetBlobInfo:(NSUInteger)blobId;

/** Use this method get information of the existing file asynchronously.
 
 @param blobId Unique blob identifier, value of ID property of the QBBlob instance.
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained. Upon finish of the request, result will be an instance of QBBlobResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */ 
+ (NSObject<Cancelable>*)GetBlobInfoAsync:(NSUInteger)blobId delegate:(NSObject<ActionStatusDelegate>*)delegate;

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
+ (Result*)DeleteBlob:(QBBlob*)blob;

/** Use this method to delete existing file asynchronously.
 
 @param blob An instance of QBBlob describing the file to be deleted.
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained. Upon finish of the request, result will be an instance of Result class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable>*)DeleteBlobAsync:(QBBlob*)blob delegate:(NSObject<ActionStatusDelegate>*)delegate;

/** @name Miscellaneous */

/** Get URL for the file on server by its UID 
 @param uid UID of the blob file, which URL to be obtained
 */
+ (NSString*)URLWithUID:(NSString*)uid;

/** @name Edit file information */

/**  The name of the file should be set if you upload instance of NSData. 
 In case you upload file from filesystem, original filename is filled in automatically
 */

@property (nonatomic, retain) NSString* name;

/** An Array of tags.
 Use tags to add additional information to your files. 
 Tags are used for searching
 */
@property (nonatomic, retain) NSArray* tags;

/** Content type in mime format */
@property (nonatomic, retain) NSString* contentType;

/** id of the file's owner */
@property (nonatomic) NSUInteger ownerID;

/** Data to be uploaded as file */
@property (nonatomic, retain) NSData* data;

/** @name Obtain file information */

/** The size of file in bytes, readonly */
@property (nonatomic) NSUInteger size;

/** Status of the File */
@property (nonatomic) QBBlobStatus status;

/** extended information about the status (optional). Usually it uses with Locked status */
@property (nonatomic, retain) NSString* extendedStatus;

/** Date when the file upload has been completed */
@property (nonatomic, retain) NSDate* completedAt;

/** File unique identifier */
@property (nonatomic, retain) NSString* UID;

/** URL for the file */
@property (nonatomic, readonly) NSURL* URL;



@end
