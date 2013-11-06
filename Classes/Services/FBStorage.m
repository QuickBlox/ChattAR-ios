//
//  DataManager.m
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 04.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "FBStorage.h"


@implementation FBStorage

static FBStorage *instance = nil;

@synthesize accessToken;

@synthesize currentFBUser;
@synthesize currentFBUserId;


+ (FBStorage *)shared {
	@synchronized (self) {
		if (instance == nil){ 
            instance = [[self alloc] init];
        }
	}
	
	return instance;
}


#pragma mark -
#pragma mark FB access

- (void)saveFBToken:(NSString *)token {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:token forKey:FBAccessTokenKey];
	[defaults synchronize];
    
    accessToken = token;
}

- (void)clearFBAccess {
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

- (void)clearFBUser {
    currentFBUser = nil;
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
