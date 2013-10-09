//
//  DataManager.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 04.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

#define maxPopularFriends 40

@interface FBStorage : NSObject{
}

// FB access
@property (nonatomic, retain) NSString				*accessToken;
@property (nonatomic, retain) NSMutableDictionary	*currentFBUser;
@property (nonatomic, retain) NSString				*currentFBUserId;


+ (FBStorage *) shared;


#pragma mark -
#pragma mark FB

- (void) saveFBToken:(NSString *)token;
- (void)clearFBAccess;
- (NSDictionary *) fbUserToken;
-(void)clearFBUser;




@end
