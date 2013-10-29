//
//  DataManager.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 04.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBStorage : NSObject

// FB access
@property (nonatomic, strong) NSString				*accessToken;
@property (nonatomic, strong) NSMutableDictionary	*currentFBUser;
@property (nonatomic, strong) NSString				*currentFBUserId;
@property (nonatomic, strong) NSArray               *friends;
@property (nonatomic, strong) NSArray               *friendsAvatarsURLs;

+ (FBStorage *) shared;


#pragma mark -
#pragma mark FB

- (void) saveFBToken:(NSString *)token;
- (void)clearFBAccess;
- (NSDictionary *) fbUserToken;
- (void)clearFBUser;




@end
