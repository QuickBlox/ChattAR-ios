//
//  Definitions.h
//  ChattAR
//
//  Created by Igor Alefirenko on 04/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#ifndef ChattAR_Definitions_h
#define ChattAR_Definitions_h

#define IS_HEIGHT_GTE_568 [[UIScreen mainScreen ] bounds].size.height >= 568.0f
#define IS_IOS_6 [[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0f

#define kNotificationDidLogin           @"kNotificationDidLogin"
#define kNotificationRowSelected        @"rowSelected"
#define kNotificationMessageReceived    @"NotificationMessageReceived"

// QBCO Request keys:
#define  kLimit      @"limit"
#define  kSkip       @"skip"
#define  kSortDesc   @"sort_desc"


// NOTIFICATIONS:
#define CAChatDidReceiveOrSendMessageNotification           @"CAChatDidReceiveOrSendMessageNotification"
#define CAChatRoomDidReceiveOrSendMessageNotification       @"CAChatRoomDidReceiveOrSendMessageNotification"
#define CAChatRoomDidEnterNotification                      @"CAChatRoomDidEnterNotification"
#define CAChatDidReceiveSearchResults                       @"CAChatDidReceiveSearchResults"

// Table Tags:
#define  kTrendingTableViewTag      1011
#define  kLocalTableViewTag         1012

#define kTrendingPaginatorTag       1001
#define kLocalPaginatorTag          1002

// Map View Tag
#define kMapViewControllerTag       1231

// TableViewCell definitions:
#define kUserName           @"username"
#define kQuote              @"quote"
#define kDateTime           @"datetime"
#define kRank               @"rank"

#define kFacebookID         @"facebookID"
#define kQuickbloxID        @"quickbloxID"

#define kRecepientID        @"recicpentID"
#define kSenderID           @"senderID"

// Segue Identifiers
#define kChatSegueIdentifier                @"Chat"
#define kMapSegueIdentifier                 @"Map"
#define kARSegueIdentifier                  @"AR"
#define kAboutSegueIdentifier               @"About"
#define kDialogsSegueIdentifier             @"Dialogs"
#define kChatToDialogSegueIdentifier        @"ChatToDialog"
#define kChatToProfileSegieIdentifier       @"ChatToProfile"
#define kDetailDialogSegueIdentifier        @"DetailDialogSegue"
#define kARToChatSegueIdentifier            @"ARToChat"
#define kMapToChatRoomSegueIdentifier       @"MapToChatRoom"
#define kChatToChatRoomSegueIdentifier      @"ChatToChatRoomSegue"
#define kDialogToProfileSegueIdentifier     @"DialogToProfile"


#define padding           20.0
#define kAnnotationButtonTag 1542

#define FB @"https://graph.facebook.com"

// Facebook Macro
#define FBAccessTokenKey       @"FBAccessTokenKey"
#define kFacebookKey           @"facebook"

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

#define APP_ID              @"464189473609303"

// QuickBlox ChatRoom Class
#define kChatRoom   @"Chatroom"

// AR
#define maxARDistance 20000000

#define minARMarkerScale 0.65f
#define countOfScaledChunks 7
#define scaleStep() (1-minARMarkerScale)/countOfScaledChunks

#define minARMarkerAlpha 0.6f
#define alphaStep() (1-minARMarkerAlpha)/countOfScaledChunks

#define kFilename @"data"

typedef void (^FBResultBlock) (id);

#endif
