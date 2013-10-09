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



static FBService *service = nil;

@implementation FBService

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
    if([FBStorage shared].currentFBUser && [Reachability internetConnected]){
        [self logInChat];
    }
}

@end
