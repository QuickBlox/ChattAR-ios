//
//  DataManager.m
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 04.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "DataManager.h"
//#import "UserAnnotation.h"

//#import "QBCheckinModel.h"
//#import "QBChatMessageModel.h"
//#import "FBCheckinModel.h"

#define kFavoritiesFriends [NSString stringWithFormat:@"kFavoritiesFriends_%@", [DataManager shared].currentFBUserId]
#define kFavoritiesFriendsIds [NSString stringWithFormat:@"kFavoritiesFriendsIds_%@", [DataManager shared].currentFBUserId]

#define kFirstSwitchAllFriends [NSString stringWithFormat:@"kFirstSwitchAllFriends_%@", [DataManager shared].currentFBUserId]

#define qbCheckinsFetchLimit 150
#define fbCheckinsFetchLimit 50
#define qbChatMessagesFetchLimit 40

#define FBCheckinModelEntity @"FBCheckinModel"
#define QBCheckinModelEntity @"QBCheckinModel"
#define QBChatMessageModelEntity @"QBChatMessageModel"

// FB Keys



@implementation DataManager

static DataManager *instance = nil;

@synthesize accessToken;

@synthesize currentQBUser;
@synthesize currentFBUser;
@synthesize currentFBUserId;

@synthesize myFriends, myFriendsAsDictionary, myPopularFriends;

@synthesize historyConversation, historyConversationAsArray;

+ (DataManager *)shared {
	@synchronized (self) {
		if (instance == nil){ 
            instance = [[self alloc] init];
        }
	}
	
	return instance;
}


#pragma mark -
#pragma mark FB access

- (void)saveFBToken:(NSString *)token{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:token forKey:FBAccessTokenKey];
	[defaults synchronize];
    
    accessToken = token;
}

- (void)clearFBAccess{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:FBAccessTokenKey];
	[defaults synchronize];

    accessToken = nil;
}

- (NSDictionary *)fbUserToken
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if ([defaults objectForKey:FBAccessTokenKey]){
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:[defaults objectForKey:FBAccessTokenKey] forKey:FBAccessTokenKey];        
		return dict;
    }
    
    return nil;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


@end
