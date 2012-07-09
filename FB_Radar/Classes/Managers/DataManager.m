//
//  DataManager.m
//  FB_Radar
//
//  Created by Sonny Black on 04.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
#import "AppDelegate.h"
#import "Constants.h"

#define kFavoritiesFriends [NSString stringWithFormat:@"kFavoritiesFriends_%@", [DataManager shared].currentFBUserId]
#define kFavoritiesFriendsIds [NSString stringWithFormat:@"kFavoritiesFriendsIds_%@", [DataManager shared].currentFBUserId]

#define kFirstSwitchAllFriends [NSString stringWithFormat:@"kFirstSwitchAllFriends_%@", [DataManager shared].currentFBUserId]

@implementation DataManager

static DataManager *instance = nil;

@synthesize accessToken, expirationDate;

@synthesize currentQBUser;
@synthesize currentFBUser;
@synthesize currentFBUserId;

@synthesize myFriends, myFriendsAsDictionary;

@synthesize historyConversation, historyConversationAsArray;

+ (DataManager *)shared {
	@synchronized (self) {
		if (instance == nil){ 
            instance = [[self alloc] init];
        }
	}
	
	return instance;
}

- (void)sortMessagesArray
{
	Conversation* temp;
	int n = [historyConversationAsArray count];
	for (int i = 0; i < n-1; i++)
	{
		for (int j = 0; j < n-1-i; j++)
		{
			NSString* date1 = [(NSMutableDictionary*)[((Conversation*)[historyConversationAsArray objectAtIndex:j]).messages lastObject] objectForKey:@"created_time"];
			NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
			[formatter1 setLocale:[NSLocale currentLocale]];
			[formatter1 setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
			NSDate *timeStamp1 = [formatter1 dateFromString:date1];
			[formatter1 release];
			
			NSString* date2 = [(NSMutableDictionary*)[((Conversation*)[historyConversationAsArray objectAtIndex:j+1]).messages lastObject] objectForKey:@"created_time"];
			NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
			[formatter2 setLocale:[NSLocale currentLocale]];
			[formatter2 setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
			NSDate *timeStamp2 = [formatter2 dateFromString:date2];
			[formatter2 release];

			if ([timeStamp1 compare:timeStamp2] == -1)
			{
				temp = [((Conversation*)[historyConversationAsArray objectAtIndex:j]) retain];
				[historyConversationAsArray replaceObjectAtIndex:j withObject:[historyConversationAsArray objectAtIndex:j+1]];
				[historyConversationAsArray replaceObjectAtIndex:j+1 withObject:temp];
				[temp release];
			}
		}
	}
}

- (id)init
{
    self = [super init];
    if (self) {
        historyConversation = [[NSMutableDictionary alloc] init];
        
        // logout
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutDone) name:kNotificationLogout object:nil];
    }
    return self;
}

-(void) dealloc 
{
    [accessToken release];
	[expirationDate release];
    
	[currentFBUser release];
	[currentQBUser release];
    [currentFBUserId release];
    
	[myFriends release];
	[myFriendsAsDictionary release];
    
	[historyConversation release];
    [historyConversationAsArray release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLogout object:nil];
	
	[super dealloc];
}

- (void)logoutDone{
    // clear defaults
    [self clearFBAccess];

    
    // reset user
    self.currentFBUser = nil;
    self.currentQBUser = nil;
    self.currentFBUserId = nil;
    
    // reset firends
    self.myFriends = nil;
    self.myFriendsAsDictionary = nil;
    
    // reset history
    [historyConversation removeAllObjects];
}


#pragma mark -
#pragma mark FB access

- (void)saveFBToken:(NSString *)token andDate:(NSDate *)date{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:token forKey:FBAccessTokenKey];
    [defaults setObject:date forKey:FBExpirationDateKey];
	[defaults synchronize];
    
    self.accessToken = token;
}

- (void)clearFBAccess{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:FBAccessTokenKey];
    [defaults removeObjectForKey:FBExpirationDateKey];
	[defaults synchronize];

    self.accessToken = nil;
}

- (NSDictionary *)fbUserTokenAndDate
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if ([defaults objectForKey:FBAccessTokenKey] && [defaults objectForKey:FBExpirationDateKey]){
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:[defaults objectForKey:FBAccessTokenKey] forKey:FBAccessTokenKey];
		[dict setObject:[defaults objectForKey:FBExpirationDateKey] forKey:FBExpirationDateKey];
        
		return dict;
    }
    
    return nil;
}


#pragma mark -
#pragma mark Friends

- (void)makeFriendsDictionary{
    if(myFriendsAsDictionary == nil){
        myFriendsAsDictionary = [[NSMutableDictionary alloc] init];
    }
    for (NSDictionary* user in [DataManager shared].myFriends){
        [myFriendsAsDictionary setObject:user forKey:[user objectForKey:kId]];
    }
}


#pragma mark -
#pragma mark Favorities friends

-(NSMutableArray *) favoritiesFriends{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *favoritiesFriends = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:kFavoritiesFriends]];
    return [favoritiesFriends autorelease];
}

-(void) addFavoriteFriend:(NSString *)_friendID
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	//already exist
	NSMutableArray *favFriends = [[DataManager shared] favoritiesFriends];
	if (favFriends == nil){
		favFriends = [[[NSMutableArray alloc] init] autorelease];
	}

	[favFriends addObject:_friendID];
	[defaults setObject:favFriends forKey:kFavoritiesFriends];
	[defaults synchronize];
}

-(void) removeFavoriteFriend:(NSString *)_friendID
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *favFriends = [[self favoritiesFriends] mutableCopy];
	
	if (favFriends == nil){
		return;
    }
	
	for (int i=0; i < [favFriends count]; i++)
	{
		if ([_friendID isEqual:[favFriends objectAtIndex:i]])
		{
			[favFriends removeObject:_friendID];
		}
	}
	[defaults setObject:favFriends forKey:kFavoritiesFriends];
	[favFriends release];
	[defaults synchronize];
}

-(BOOL) friendIDInFavorities:(NSString *)_friendID{
    NSMutableArray *favFriends = [self favoritiesFriends];
    if([favFriends containsObject:_friendID]){
        return YES;
    }
    
    return NO;
}


#pragma mark -
#pragma mark First switch All/Friends

- (BOOL)isFirstStartApp{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *firstStartApp = [defaults objectForKey:kFirstSwitchAllFriends];
    if(firstStartApp == nil){
        return YES;
    }
    return  [firstStartApp boolValue];
}

- (void)setFirstStartApp:(BOOL)firstStartApp{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:firstStartApp] forKey:kFirstSwitchAllFriends];
    [defaults synchronize];
}


#pragma mark -
#pragma mark QuickBlox Quote

- (NSString *)originMessageFromQuote:(NSString *)quote{
    if([quote length] > 6){
        if ([[quote substringToIndex:6] isEqualToString:fbidIdentifier])
		{
            return [quote substringFromIndex:[quote rangeOfString:quoteDelimiter].location+1];
        }
    }
    
    return quote;
}

- (NSString *)messageFromQuote:(NSString *)quote{
    if([quote length] > 6){
        if ([[quote substringToIndex:6] isEqualToString:fbidIdentifier]){
            return [quote substringFromIndex:[quote rangeOfString:quoteDelimiter].location+1];
        }
    }
    
    return quote;
}

@end
