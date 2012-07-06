//
//  DataManager.h
//  FB_Radar
//
//  Created by Sonny Black on 04.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (nonatomic, retain) NSString				*accessToken;
@property (nonatomic, retain) NSDate				*expirationDate;

// current User
@property (nonatomic, retain) QBUUser				*currentQBUser;
@property (nonatomic, retain) NSMutableDictionary	*currentFBUser;
@property (nonatomic, retain) NSString				*currentFBUserId;

// friends
@property (nonatomic, retain) NSMutableArray		*myFriends;
@property (nonatomic, retain) NSMutableDictionary	*myFriendsAsDictionary;

// messages
@property (nonatomic, retain) NSMutableDictionary	*historyConversation;
@property (nonatomic, retain) NSMutableArray	*historyConversationAsArray;

+ (DataManager *) shared;

- (void)sortMessagesArray;

#pragma mark -
#pragma mark Friends

- (void)makeFriendsDictionary;


#pragma mark -
#pragma mark FB

- (void) saveFBToken:(NSString *)token andDate:(NSDate *)date;
- (void)clearFBAccess;
- (NSDictionary *) fbUserTokenAndDate;


#pragma mark -
#pragma mark Favorities friends

-(NSMutableArray *) favoritiesFriends;
-(void) addFavoriteFriend: (NSString *)_friendID;
-(void) removeFavoriteFriend: (NSString *)_friendID;
-(BOOL) friendIDInFavorities:(NSString *)_friendID;


#pragma mark -
#pragma mark First switch All/Friends

- (BOOL)isFirstStartApp;
- (void)setFirstStartApp:(BOOL)firstStartApp;


#pragma mark -
#pragma mark QuickBlox Quote

- (NSString *)originMessageFromQuote:(NSString *)quote;
- (NSString *)messageFromQuote:(NSString *)quote;

@end
