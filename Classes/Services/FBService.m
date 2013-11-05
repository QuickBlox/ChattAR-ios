//
//  FBService.m
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 07.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
#import "FBService.h"
#import "XMPPFramework.h"
#import "DDTTYLogger.h"
#import "XMPPStream.h"
#import "FBStorage.h"
#import "FBChatService.h"
#import "Utilites.h"
#import "NSObject+performer.h"



static FBService *service = nil;

@implementation FBService
@synthesize fbChatRoomDidEnter;

#pragma mark -
#pragma mark Singletone

+ (FBService *)shared {
	@synchronized (self) {
		if (service == nil){
            service = [[self alloc] init];
        }
	}
	
	return service;
}

- (id)init{
    self = [super init];
    if (self) {
		xmppStream = [[XMPPStream alloc] initWithFacebookAppId:APP_ID];
		[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        fbChatRoomDidEnter = NO;
    }
    return self;
}


#pragma mark -
#pragma mark Me

// Get profile
- (void) userProfileWithResultBlock:(FBResultBlock)resultBlock{
    FBRequest *meRequest = [FBRequest requestForMe];
    [meRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        resultBlock(result);
    }];
}


#pragma mark -
#pragma mark Friends

- (void) userFriendsUsingBlock:(FBResultBlock)resultBlock{
    FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        resultBlock(result);
    }];
}


#pragma mark -
#pragma mark User with ID

- (void) userProfileWithID:(NSString *)userID withBlock:(FBResultBlock)resultBlock{
    FBRequest *requestForID = [FBRequest requestForGraphPath:userID];
    [requestForID startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        resultBlock(result);
    }];
}


#pragma mark -
#pragma mark Messages

-(void) logInChat
{
	NSError *error = nil;
	[xmppStream connectWithTimeout:30 error:&error];
}

-(void) logOutChat{
    [xmppStream disconnect];
}

- (void) sendMessageToFacebook:(NSString*)textMessage withFriendFacebookID:(NSString*)friendID {
    if([textMessage length] > 0) {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:textMessage];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        //        [message addAttributeWithName:@"xmlns" stringValue:@"http://www.facebook.com/xmpp/messages"];
        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"-%@@chat.facebook.com",friendID]];
        [message addChild:body];
        [xmppStream sendElement:message];
    }
}

- (void) inboxMessagesWithDelegate:(NSObject <FBServiceResultDelegate>*)delegate {
    NSString *urlString = [NSString stringWithFormat:@"%@/me/inbox?access_token=%@",FB, [FBStorage shared].accessToken];
    [self performRequestAsyncWithUrl:urlString request:nil type:FBQueriesTypesGetInboxMessages delegate:delegate];
}



#pragma mark -
#pragma mark Chat API

-(void) sendPresence
{
	XMPPPresence *presence = [XMPPPresence presence];
	[xmppStream sendElement:presence];
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    if (![xmppStream isSecure])
    {
        NSError *error = nil;
        BOOL result = [xmppStream secureConnection:&error];
        
        if (result == NO)
        {
            NSLog(@"XMPP STARTTLS failed");
        }
    } 
    else 
    {
        NSError *error = nil;
		BOOL result = [xmppStream authenticateWithFacebookAccessToken:GetFBAccessToken error:&error];

        if (result == NO)
        {
            NSLog(@"XMPP authentication failed");
        }
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"Facebook XMPP authenticated");
    presenceTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self 
                                                    selector:@selector(sendPresence) 
                                                    userInfo:nil repeats:YES];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"XMPP authentication failed");
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"FB Chat Authenticate Fail" message:@"Please restart application" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    presenceTimer = nil;
    NSLog(@"XMPP disconnected");
    
    // reconnect if disconnected
    if([Reachability internetConnected]){
        [self logInChat];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	[self backgroundMessageReceived:message];
}

- (void) backgroundMessageReceived:(XMPPMessage *)textMessage
{
	NSString *body = [[textMessage elementForName:kBody] stringValue];
    if (body == nil) {
        return;
    }
    
    NSMutableString *fromID = [[textMessage attributeStringValueForName:kFrom] mutableCopy];
    [fromID replaceCharactersInRange:NSMakeRange(0, 1) withString:@""]; // remove -
    [fromID replaceOccurrencesOfString:@"@chat.facebook.com" withString:@""
                               options:0 range:NSMakeRange(0, [fromID length])]; // remove @chat.facebook.com
    NSArray *friends = [FBStorage shared].friends;
    NSDictionary *friend = [[NSDictionary alloc] init];
    // find opponent:
    for (NSDictionary *myFriend in friends) {
        if ([[myFriend objectForKey:kId] isEqual:fromID]) {
            friend = myFriend;
            break;
        }
    }
    if(friend == nil){
        return;
    } else {
        // creating message:
        NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
        // user info:
        NSMutableDictionary *from = [[NSMutableDictionary alloc] init];
        [from setValue:[friend objectForKey:kId] forKey:kId];
        [from setValue:[friend objectForKey:kName] forKey:kName];
        
        [message setValue:from forKey:kFrom];
        [message setValue:body forKey:kMessage];
        
        NSDate *date = [NSDate date];
        [[Utilites shared].dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
        NSString *createdTime = [[Utilites shared].dateFormatter stringFromDate:date];
        [message setValue:createdTime forKey:kCreatedTime];
        // back to default format mode
        [[Utilites shared].dateFormatter setDateFormat:@"HH:mm"];
        [[[[[FBChatService defaultService].allFriendsHistoryConversation objectForKey:fromID] objectForKey:kComments] objectForKey:kData
          ] addObject:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageReceived object:nil];
    }
    
    
}

#pragma mark -
#pragma mark Core

- (void) performRequestAsyncWithUrl:(NSString *)urlString request: (NSURLRequest*)request
                               type: (FBQueriesTypes)queryType
                           delegate:(NSObject <FBServiceResultDelegate>*)delegate{
    
    [self  performRequestAsyncWithUrl:urlString request:request type:queryType delegate:delegate context:nil];
}

- (void) performRequestAsyncWithUrl:(NSString *)urlString request: (NSURLRequest*)request
                               type:(FBQueriesTypes) queryType
                           delegate:(NSObject <FBServiceResultDelegate>*)delegate
                            context:(id) context
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if([urlString length]){
        NSURL *url;
		url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        request = [NSURLRequest requestWithURL:url];
    }
    
    //NSLog(@"performRequestAsyncWithUrl=%@", [[request URL] absoluteString]);
    
    NSArray *params = [NSArray arrayWithObjects:request, [NSNumber numberWithInt:queryType], delegate, context, nil];
    [self performSelectorInBackground:@selector(actionInBackground:) withObject:params];
}

- (void)actionInBackground:(NSArray *)params{
    @autoreleasepool {
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        
        NSURLRequest *request = [params objectAtIndex:0];
        FBQueriesTypes queryType = (FBQueriesTypes)[[params objectAtIndex:1] intValue];
        NSObject <FBServiceResultDelegate>* delegate = [params objectAtIndex:2];
        id context = nil;
        if([params count] == 4){
            context = [params objectAtIndex:3];
        }

        // perform request
        NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        // alloc result
        FBServiceResult *result = [[FBServiceResult alloc] init];
        
        // set body
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
        
        result.body = jsonDict;

		// set context
		result.context = (NSString*)context;
        
        // set query type
        [result setQueryType:queryType];
        
        // return result to delegate
        if(context){
            [delegate performSelectorOnMainThread:@selector(completedWithFBResult:context:) withObject:result withObject:context waitUntilDone:YES];
        }else{
            [delegate performSelectorOnMainThread:@selector(completedWithFBResult:) withObject:result waitUntilDone:YES];
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

@end
