//
//  Definitions.h
//  FB_Radar
//
//  Created by Sonny Black on 07.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef FB_Radar_Definitions_h
#define FB_Radar_Definitions_h

#define FB @"https://graph.facebook.com"

#define kMe					@"me"
#define kResponse			@"response"
#define kData				@"data" 
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
#define	kCreatedTime		@"created_time"
#define	kUpdatedTime		@"updated_time"
#define kFavorites			@"favorites"
#define kComments           @"comments"

#define kGET                @"GET"

// QB Chat 
#define nameIdentifier @"@name="
#define dateIdentifier @"@date="
#define photoIdentifier @"@photo="
#define messageIdentifier @"@msg="
#define fbidIdentifier @"@fbid="
#define quoteDelimiter @"|"


// online-offline statuses
#define kOnOffStatus		@"on/off"
#define kOnline				[NSNumber numberWithInt:1]
#define kOffline			[NSNumber numberWithInt:0]

//Friends
#define fbAPIMethodNameFriendsGet @"friends"


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
    FBQueriesTypesGetInboxMessages,	
    
} FBQueriesTypes;

#endif
