//
//  UserAnnotation.m
//  Fbmsg
//
//  Created by Igor Khomenko on 3/28/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "UserAnnotation.h"

@implementation UserAnnotation
@synthesize userPhotoUrl, userName, userStatus, coordinate, fbUserId, geoDataID, createdAt, fbUser, quotedUserName, quotedMessageDate, quotedMessageText, quotedUserPhotoURL, distance, quotedUserFBId, qbUserID;

- (void)dealloc
{
	[quotedMessageDate release];
	[quotedMessageText release];
	[quotedUserName release];
	[quotedUserPhotoURL release];
	[quotedUserFBId release];
    
    [userPhotoUrl release];
    [userName release];
    [userStatus release];
    [createdAt release];
    [fbUserId release];
    [fbUser release];
    
    [super dealloc];
}

@end
