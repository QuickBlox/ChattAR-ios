//
//  FBService.m
//  FB_Radar
//
//  Created by Sonny Black on 07.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FBService.h"
#import "FBChatViewController.h"
#import "NSObject+performer.h"
#import "XMPP.h"
#import "AppDelegate.h"
#import "DDLog.h"
#import "DDTTYLogger.h"


static const int ddLogLevel = LOG_LEVEL_VERBOSE;

static FBService *instance = nil;

@implementation FBService
@synthesize facebook, isChatDidConnect;


#pragma mark -
#pragma mark Singletone

+ (FBService *)shared {
	@synchronized (self) {
		if (instance == nil){ 
            instance = [[self alloc] init];
        }
	}
	
	return instance;
}

- (id)init{
    self = [super init];
    if (self) {
        facebook = [[Facebook alloc] initWithAppId:APP_ID andDelegate:nil];
		
		[DDLog addLogger:[DDTTYLogger sharedInstance]];
		
		xmppStream = [[XMPPStream alloc] initWithFacebookAppId:APP_ID];
		[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
		
		allowSelfSignedCertificates = NO;
		allowSSLHostNameMismatch = NO;
		
		isChatDidConnect = NO;
    }
    return self;
}

-(void) dealloc
{
	[super dealloc];
	
    [facebook release];
	[presenceTimer release];
	[xmppStream release];
}


#pragma mark -
#pragma mark API


#pragma mark -
#pragma mark Me

// Get profile
- (void) userProfileWithDelegate:(NSObject <FBServiceResultDelegate> *)delegate{

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"id,name,picture,hometown,location" forKey:kFields];
    
    // query to FB
    [facebook requestWithGraphPath:kMe andParams:params andHttpMethod:kGET andDelegate:self andFBServiceDelegate:delegate type:FBQueriesTypesUserProfile];
}


#pragma mark -
#pragma mark Users

- (void) usersProfilesWithIds:(NSString*)ids delegate:(NSObject <FBServiceResultDelegate>*)delegate context:(id)context
{
    NSString *urlString = [NSString stringWithFormat:@"%@/?ids=%@&fields=picture,name,first_name,last_name&access_token=%@",
                           FB,
                           ids,
                           [FBService shared].facebook.accessToken];

    [self performRequestAsyncWithUrl:urlString request:nil type:FBQueriesTypesUsersProfiles delegate:delegate context:context];
}


#pragma mark -
#pragma mark Friends

// get friends
- (void) friendsGetWithDelegate:(NSObject <FBServiceResultDelegate>*)delegate
{
	// url
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@?%@=%@,%@,%@,%@,%@&access_token=%@",
                           FB,
                           kMe,
						   fbAPIMethodNameFriendsGet,
						   kFields,
						   kPicture,
						   kId,
						   kName,
                           kFirstName,
                           kLastName,
                           //kStatuses,
                           [FBService shared].facebook.accessToken];
	
    [self performRequestAsyncWithUrl:urlString request:nil type:FBQueriesTypesFriendsGet delegate:delegate];
}

- (void) friendsCheckinsWithDelegate:(NSObject <FBServiceResultDelegate>*)delegate
{
	NSMutableString *batchRequestBody = [[NSMutableString alloc] initWithString:@"["];
    
    [batchRequestBody appendString:@"{ \"method\": \"GET\",  \"relative_url\": \"me/locations?with=location,id\" },"];
    
    BOOL lastSend = NO;
	for(int i=0; i<[[DataManager shared].myFriends count]; ++i)
	{
        // Limits
        // Facebook: "We currently limit the number of batch requests to 50."
        if(i % 49 == 0 && i != 0){
            lastSend = YES;
            
            [batchRequestBody deleteCharactersInRange:NSMakeRange([batchRequestBody length]-1, 1)]; // remove last ,
            [batchRequestBody appendString:@"]"];
            
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:batchRequestBody forKey:@"batch"];
            [batchRequestBody release];
            
            // Delegate
            [facebook requestWithGraphPath:@"" andParams:params andHttpMethod:@"POST" andDelegate:self andFBServiceDelegate:delegate type:FBQueriesTypesFriendsGetCheckins];
            
            
            batchRequestBody = [[NSMutableString alloc] initWithString:@"["];
            NSDictionary *friend = [[DataManager shared].myFriends objectAtIndex:i];
            [batchRequestBody appendFormat:@"{ \"method\": \"GET\",  \"relative_url\": \"%@/locations?with=location,id\" },", 
             [friend objectForKey:kId]];
            
        }else{
            NSDictionary *friend = [[DataManager shared].myFriends objectAtIndex:i];
            [batchRequestBody appendFormat:@"{ \"method\": \"GET\",  \"relative_url\": \"%@/locations?with=location,id\" },", 
             [friend objectForKey:kId]];
            
            lastSend = NO;
        }
	} 
    
    if(!lastSend){
        [batchRequestBody deleteCharactersInRange:NSMakeRange([batchRequestBody length]-1, 1)]; // remove last ,
        [batchRequestBody appendString:@"]"];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:batchRequestBody forKey:@"batch"];
        [batchRequestBody release];
        
        // Delegate
        [facebook requestWithGraphPath:@"" andParams:params andHttpMethod:@"POST" andDelegate:self andFBServiceDelegate:delegate type:FBQueriesTypesFriendsGetCheckins];
    }
}


#pragma mark -
#pragma mark Messages

- (void) inboxMessagesWithDelegate:(NSObject <FBServiceResultDelegate>*)delegate
{	
    NSString *urlString = [NSString stringWithFormat:@"%@/me/inbox?access_token=%@",FB, [FBService shared].facebook.accessToken];
    
    [self performRequestAsyncWithUrl:urlString request:nil type:FBQueriesTypesGetInboxMessages delegate:delegate];
}

-(void) logInChat
{
	NSError *error = nil;
	[xmppStream connect:&error];
}

-(void) logOutChat{
    [xmppStream disconnect];
}

- (void)sendMessageToFacebook:(NSString*)textMessage withFriendFacebookID:(NSString*)friendID {
	
    if([textMessage length] > 0) {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:textMessage];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"xmlns" stringValue:@"http://www.facebook.com/xmpp/messages"];
        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"-%@@chat.facebook.com",friendID]];
        [message addChild:body];
        [xmppStream sendElement:message];
    }
}


#pragma mark -
#pragma mark FBRequestDelegate

-(void)request:(FBRequest *)request didLoad:(id)result {
	//	
	FBServiceResult *parserResult = [[FBServiceResult alloc] init];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	
    // get checkins messages
    if (request.query == FBQueriesTypesFriendsGetCheckins){

		for (int i =0;i < [result count]; i++){
            NSDictionary *res = [result objectAtIndex:i];
            if(![res isKindOfClass:NSDictionary.class]){
                continue;
            }
			parserResult.body = [parser objectWithString:(NSString *)([res  objectForKey:@"body"])];
			parserResult.queryType = request.query;
			[request.del completedWithFBResult:parserResult];
		}
    
    // Me
	}else{
        parserResult.body = result;
        parserResult.queryType = request.query;
        [request.del completedWithFBResult:parserResult];
    }
	
	[parserResult release];
	[parser release];
	
}

-(void)request: didFailWithError:(NSError *)error
{
	NSLog(@"didFailWithError: %@", error);
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
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
    if (![xmppStream isSecure])
    {
        NSError *error = nil;
        BOOL result = [xmppStream secureConnection:&error];
        
        if (result == NO)
        {
            DDLogError(@"%@: Error in xmpp STARTTLS: %@", THIS_FILE, error);
            NSLog(@"XMPP STARTTLS failed");
        }
    } 
    else 
    {
        NSError *error = nil;
		BOOL result = [xmppStream authenticateWithFacebookAccessToken:facebook.accessToken error:&error];

        if (result == NO)
        {
            DDLogError(@"%@: Error in xmpp auth: %@", THIS_FILE, error);
            NSLog(@"XMPP authentication failed");
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		NSString *expectedCertName = [sender hostName];
		if (expectedCertName == nil)
		{
			expectedCertName = [[sender myJID] domain];
		}
        
		[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSLog(@"XMPP STARTTLS...");
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSLog(@"XMPP authenticated");
    
	isChatDidConnect = YES;
    
    presenceTimer = [[NSTimer scheduledTimerWithTimeInterval:30 target:self 
                                                    selector:@selector(sendPresence) 
                                                    userInfo:nil repeats:YES] retain];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@ - error: %@", THIS_FILE, THIS_METHOD, error);
    NSLog(@"XMPP authentication failed");
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"FB Chat Authenticate Fail" message:@"Please restart application" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
    [alertView release];
    
    isChatDidConnect = NO;
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    isChatDidConnect = NO;
    
    [presenceTimer release];
    presenceTimer = nil;
    
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSLog(@"XMPP disconnected");
    
    // reconnect if disconnected
    if([DataManager shared].currentFBUser){
        [self logInChat];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message 
{
	[self backgroundMessageReceived:message];
}
 
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
	 NSLog(@"XMPP disconnected");
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	[self receiveFriendPresence:(XMPPPresence *)presence];
}


- (void) receiveFriendPresence:(XMPPPresence *)presence
{
    // is Unavailable ?
	NSString *unavaible = [presence attributeStringValueForName:@"type"];
	
	NSMutableString *fromID = [[presence attributeStringValueForName:kFrom] mutableCopy]; // like -1621286874@chat.facebook.com
    
	[fromID replaceCharactersInRange:NSMakeRange(0, 1) withString:@""]; // remove -
	[fromID replaceOccurrencesOfString:@"@chat.facebook.com" withString:@"" options:0 range:NSMakeRange(0, [fromID length])]; // remove @chat.facebook.com
	
    NSNumber *status;
    // Unavailable -> offline
	if (unavaible){
        status = kOffline;

    // available -> online
	}else{		
        status = kOnline;
    }
    
    // set friend status
    NSMutableDictionary *friend = [[DataManager shared].myFriendsAsDictionary objectForKey:fromID];
    [friend setObject:status forKey:kOnOffStatus];
    
    [fromID release];
    
    // notify application
    [[NSNotificationCenter defaultCenter] postNotificationName:kReceivedOnlineStatus object:nil];
}

- (void) backgroundMessageReceived:(XMPPMessage *)textMessage
{
	NSString *body = [[textMessage elementForName:@"body"] stringValue];
    if(body == nil){
        return;
    }

    // message datetime
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
    NSString *timeStamp = [formatter stringFromDate:now];
    [formatter release];
    
    // from
    NSMutableString *fromID = [[textMessage attributeStringValueForName:@"from"] mutableCopy]; // like -1621286874@chat.facebook.com
    [fromID replaceCharactersInRange:NSMakeRange(0, 1) withString:@""]; // remove -
    [fromID replaceOccurrencesOfString:@"@chat.facebook.com" withString:@"" 
                               options:0 range:NSMakeRange(0, [fromID length])]; // remove @chat.facebook.com


    // construct new message
    NSMutableDictionary *recievedMessage  = [[NSMutableDictionary alloc] init];
    
    // set message datetime
    [recievedMessage setObject:timeStamp forKey:kCreatedTime];
    
    // set opponent's info
    NSMutableDictionary *opponent = [[NSMutableDictionary alloc] init];
    NSDictionary *friend = [[DataManager shared].myFriendsAsDictionary objectForKey:fromID];
    [opponent setObject:[friend objectForKey:kId] forKey:kId];
    [opponent setObject:[friend objectForKey:kName] forKey:kName];
    [recievedMessage setObject:opponent forKey:kFrom];
    [opponent release];

    // set body
    [recievedMessage  setObject:body forKey:kMessage];
    
    // get conversation
    Conversation *conversation = [[DataManager shared].historyConversation objectForKey:fromID];
    if(conversation == nil){
        Conversation *newConversation = [[Conversation alloc] init];
        
        // add to
        NSMutableDictionary *to = [NSMutableDictionary dictionary];
        [to setObject:[friend objectForKey:kId] forKey:kId];
        [to setObject:[friend objectForKey:kName] forKey:kName];
        newConversation.to = to;
        
        // add messages
        NSMutableArray *emptryArray = [[NSMutableArray alloc] init];
        newConversation.messages = emptryArray;
        [emptryArray release];
        
        [[DataManager shared].historyConversation setObject:newConversation forKey:fromID];
        [newConversation release];
        
        conversation = newConversation;
    }
    
    [conversation.messages addObject:recievedMessage];

    
    [fromID release];
    [recievedMessage release];
    
    
    [DataManager shared].historyConversationAsArray = [[[[DataManager shared].historyConversation allValues] mutableCopy] autorelease];
    [[DataManager shared].historyConversationAsArray removeObject:conversation];
    [[DataManager shared].historyConversationAsArray insertObject:conversation atIndex:0];

    // notify application
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewChatMessageCome object:nil];
    //
    // play notify
    [NotificationManager playNotificationSoundAndVibrate];
    
    
    //
    // ++ badge
    if(!conversation.isUnRead){
        UITabBarController *tabBarController = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).tabBarController;
        int badge = [((UITabBarItem *)[tabBarController.tabBar.items objectAtIndex:0]).badgeValue intValue];
        ++badge;
        //
        ((UITabBarItem *)[tabBarController.tabBar.items objectAtIndex:0]).badgeValue = [NSString stringWithFormat:@"%d", badge];
        
        conversation.isUnRead = YES;
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
    
    NSLog(@"performRequestAsyncWithUrl=%@", [[request URL] absoluteString]);
    
    NSArray *params = [NSArray arrayWithObjects:request, [NSNumber numberWithInt:queryType], delegate, context, nil];
    [self performSelectorInBackground:@selector(actionInBackground:) withObject:params];
}

- (void)actionInBackground:(NSArray *)params{
    @autoreleasepool {
        
        NSURLResponse **response = nil;
        NSError **error = nil;
        
        NSURLRequest *request = [params objectAtIndex:0];
        FBQueriesTypes queryType = (FBQueriesTypes)[[params objectAtIndex:1] intValue];
        NSObject <FBServiceResultDelegate>* delegate = [params objectAtIndex:2];
        id context = nil;
        if([params count] == 4){
            context = [params objectAtIndex:3];
        }
        
        
        // perform request
        NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:response error:error];
        
        // alloc result
        FBServiceResult *result = [[FBServiceResult alloc] init];
        
        // set body
        NSString *bodyAsString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        result.body = [parser objectWithString:bodyAsString];
        [bodyAsString release];
        [parser release];
        
		// set context
		result.context = (NSString*)context;
               
        // set query type
        [result setQueryType:queryType];
        
        //NSLog(@"responseResult=%@",result.body);
        
        // return result to delegate 
        if(context){
            [delegate performSelectorOnMainThread:@selector(completedWithFBResult:context:) withObject:[result autorelease] withObject:context waitUntilDone:YES];
        }else{
            [delegate performSelectorOnMainThread:@selector(completedWithFBResult:) withObject:[result autorelease] waitUntilDone:YES];
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}


@end
