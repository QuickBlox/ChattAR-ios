/*
 *  Consts.h
 *  BlobsService
 *

 *  Copyright 2010 QuickBlox team. All rights reserved.
 *
 */


extern NSString* const kBlobsServiceException;
extern NSString* const kBlobsServiceErrorDomain;
extern NSString* const kBlobsS3ErrorDomain;

//Exceptions
extern NSString* const kBlobsServiceExceptionUnknownOwnerType;

//Owner Types
extern NSString* const kBlobsServiceBlobOwnerTypeApplication;
extern NSString* const kBlobsServiceBlobOwnerTypeService;
extern NSString* const kBlobsServiceBlobOwnerTypeUser;

extern enum QBBlobSortByKind kBlobsServiceDefaultSort;
extern BOOL kBlobsServiceDefaultSortIsAsc;

//S3 Error Keys

extern NSString* const kBlobsS3ErrorKeyCode;
extern NSString* const kBlobsS3ErrorKeyMessage;
extern NSString* const kBlobsS3ErrorKeyRequestId;
extern NSString* const kBlobsS3ErrorKeyHostId;

#define EBL(B,C) E(kBlobsServiceException, B,C)
#define EBL2(B) E2(kBlobsServiceException, B)

#define blobsElement @"blobs"
#define blobElement @"blob"
