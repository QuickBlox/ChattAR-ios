//
//  Definitions.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 07.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#define FB @"https://graph.facebook.com"

#define kMe					@"me"
#define kResponse			@"response"
#define kData				@"data" 
#define kUrl				@"url"
#define kName				@"name"
#define kPicture			@"picture"
#define kLocation			@"location"
#define kHometown			@"hometown"
#define kStatuses			@"statuses"
#define kFields				@"fields"
#define kMessage			@"message"
#define kId					@"id"
#define kFirstName			@"first_name"
#define kLastName			@"last_name"
#define kInbox				@"inbox"
#define kComments			@"comments"
#define kLikes              @"likes"
#define kFrom				@"from"
#define kTo					@"to"
#define kBody				@"body"
#define kId                 @"id"
#define kPlace              @"place"
#define kPhoto              @"photo"
#define kUserFirstName      @"first_name"
#define kCountry            @"country"
#define kCity               @"city"
#define kLatitude           @"latitude"
#define kLongitude          @"longitude"
#define kDate               @"date"
#define kFbID               @"fbid"
#define kQbID               @"qbid"
#define	kCreatedTime		@"created_time"
#define	kUpdatedTime		@"updated_time"
#define kFavorites			@"favorites"
#define kComments           @"comments"
#define kError              @"error"
#define kPaging             @"paging"
#define kNext               @"next"

#define kGET                @"GET"

// QB Chat 
#define nameIdentifier @"@name="
#define dateIdentifier @"@date="
#define photoIdentifier @"@photo="
#define messageIdentifier @"@msg="
#define fbidIdentifier @"@fbid="
#define qbidIdentifier @"@qbid="
#define quoteDelimiter @"|"


// online-offline statuses
#define kOnOffStatus		@"on/off"
#define kOnline				[NSNumber numberWithInt:1]
#define kOffline			[NSNumber numberWithInt:0]

//Friends
#define fbAPIMethodNameFriendsGet @"friends"

#define maxRequestsInBatch 50
#define fmaxRequestsInBatch 50.f


// methods type

typedef enum {
    // Me
    FBQueriesTypesUserProfile,
    //
    // Friends
    FBQueriesTypesFriendsGet,
	FBQueriesTypesFriendsGetCheckins,
	FBQueriesTypesUsersProfiles,
    //
    FBQueriesTypesWall,
    FBQueriesTypesGetInboxMessages,	
    
} FBQueriesTypes;
