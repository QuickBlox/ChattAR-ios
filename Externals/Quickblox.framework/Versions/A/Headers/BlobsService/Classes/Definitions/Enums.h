//
//  Enums.h
//  BlobsService
//

//  Copyright 2010 QuickBlox team. All rights reserved.

/** Kind of sorting */
typedef enum QBBlobSortByKind{
    /** No sorting */    
	QBBlobSortByKindNone = 0,
    /** Sort by CreatedAt */
	QBBlobSortByKindCreatedAt = 1,     
    /** Sort by size */
	QBBlobSortByKindSize = 2
} QBBlobSortByKind;

typedef enum QBBlobOwnerType{
	QBBlobOwnerTypeApplication,
	QBBlobOwnerTypeService,
	QBBlobOwnerTypeUser
} QBBlobOwnerType;

typedef enum QBBlobStatus{
    
	QBBlobStatusNew,
	QBBlobStatusLocked,
	QBBlobStatusCompleted
} QBBlobStatus;

typedef enum QBBlobObjectAccessType{
	QBBlobObjectAccessTypeRead,
	QBBlobObjectAccessTypeWrite
} QBBlobObjectAccessType;