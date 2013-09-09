//
//  DataManager.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 04.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

#define maxPopularFriends 40

@interface DataManager : NSObject{
    // Core Data
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

// FB access
@property (nonatomic, retain) NSString				*accessToken;
@property (nonatomic, retain) NSDate				*expirationDate;

// current User
@property (nonatomic, retain) QBUUser				*currentQBUser;
@property (nonatomic, retain) NSMutableDictionary	*currentFBUser;
@property (nonatomic, retain) NSString				*currentFBUserId;

// friends
@property (nonatomic, retain) NSMutableArray		*myFriends;
@property (nonatomic, retain) NSMutableDictionary	*myFriendsAsDictionary;
@property (nonatomic, retain) NSMutableSet		    *myPopularFriends;

// messages
@property (nonatomic, retain) NSMutableDictionary	*historyConversation;
@property (nonatomic, retain) NSMutableArray	    *historyConversationAsArray;

// Core Data
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DataManager *) shared;

- (void)sortMessagesArray;

- (void)clearCache;

#pragma mark -
#pragma mark Friends

- (void)makeFriendsDictionary;
- (void)addPopularFriendID:(NSString *)friendID;


#pragma mark -
#pragma mark FB

- (void) saveFBToken:(NSString *)token;
- (void)clearFBAccess;
- (NSDictionary *) fbUserToken;
-(void)clearFBUser;




@end
