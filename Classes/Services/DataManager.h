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
}

// FB access
@property (nonatomic, retain) NSString				*accessToken;
@property (nonatomic, retain) NSDate				*expirationDate;
// cached users
@property (nonatomic, retain) NSMutableDictionary   *fbUsersLoggedIn;
// current User
@property (nonatomic, retain) QBUUser				*currentQBUser;
@property (nonatomic, retain) NSMutableDictionary	*currentFBUser;
@property (nonatomic, retain) NSString				*currentFBUserId;
@property (nonatomic, retain) QBChatRoom            *chatRoom;

+ (DataManager *) shared;


#pragma mark -
#pragma mark FB

- (void) saveFBToken:(NSString *)token;
- (void)clearFBAccess;
- (NSDictionary *) fbUserToken;
-(void)clearFBUser;




@end
