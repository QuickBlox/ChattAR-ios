//
//  UserAnnotation.m
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 3/28/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "UserAnnotation.h"
#import "Macro.h"

@implementation UserAnnotation
@synthesize userPhotoUrl, userName, userStatus, coordinate, fbUserId, geoDataID, createdAt, fbUser, quotedUserName, quotedMessageDate, quotedMessageText, quotedUserPhotoURL, distance, quotedUserFBId, quotedUserQBId, qbUserID, fbCheckinID, fbPlaceID;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
        DESERIALIZE_OBJECT(userPhotoUrl, aDecoder);
        DESERIALIZE_OBJECT(userName, aDecoder);
        DESERIALIZE_OBJECT(userStatus, aDecoder);
        DESERIALIZE_DOUBLE(coordinate.latitude, aDecoder);
        DESERIALIZE_DOUBLE(coordinate.longitude, aDecoder);
        DESERIALIZE_OBJECT(createdAt, aDecoder);
        
        DESERIALIZE_OBJECT(fbUser, aDecoder);
        DESERIALIZE_OBJECT(fbUserId, aDecoder);
        DESERIALIZE_INT(geoDataID, aDecoder);
        DESERIALIZE_OBJECT(fbCheckinID, aDecoder);
        DESERIALIZE_OBJECT(fbPlaceID, aDecoder);
        DESERIALIZE_INT(qbUserID, aDecoder);
        
        DESERIALIZE_INT(distance, aDecoder);
        
        DESERIALIZE_OBJECT(quotedUserFBId, aDecoder);
        DESERIALIZE_OBJECT(quotedUserQBId, aDecoder);
        DESERIALIZE_OBJECT(quotedUserPhotoURL, aDecoder);
        DESERIALIZE_OBJECT(quotedUserName, aDecoder);
        DESERIALIZE_OBJECT(quotedMessageDate, aDecoder);
        DESERIALIZE_OBJECT(quotedMessageText, aDecoder);
	}
	
	return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    SERIALIZE_OBJECT(userPhotoUrl, aCoder);
    SERIALIZE_OBJECT(userName, aCoder);
    SERIALIZE_OBJECT(userStatus, aCoder);
    SERIALIZE_DOUBLE(coordinate.latitude, aCoder);
    SERIALIZE_DOUBLE(coordinate.longitude, aCoder);
    SERIALIZE_OBJECT(createdAt, aCoder);
    
    SERIALIZE_OBJECT(fbUser, aCoder);
    SERIALIZE_OBJECT(fbUserId, aCoder);
    SERIALIZE_INT(geoDataID, aCoder);
    SERIALIZE_OBJECT(fbCheckinID, aCoder);
    SERIALIZE_OBJECT(fbPlaceID, aCoder);
    SERIALIZE_INT(qbUserID, aCoder);
    
    SERIALIZE_INT(distance, aCoder);
    
    SERIALIZE_OBJECT(quotedUserFBId, aCoder);
    SERIALIZE_OBJECT(quotedUserQBId, aCoder);
    SERIALIZE_OBJECT(quotedUserPhotoURL, aCoder);
    SERIALIZE_OBJECT(quotedUserName, aCoder);
    SERIALIZE_OBJECT(quotedMessageDate, aCoder);
    SERIALIZE_OBJECT(quotedMessageText, aCoder);
}

- (void)dealloc
{
	[quotedMessageDate release];
	[quotedMessageText release];
	[quotedUserName release];
	[quotedUserPhotoURL release];
	[quotedUserFBId release];
    [quotedUserQBId release];
    
    [userPhotoUrl release];
    [userName release];
    [userStatus release];
    [createdAt release];
    [fbUserId release];
    [fbUser release];
    [fbCheckinID release];
    [fbPlaceID release];
    
    [super dealloc];
}

- (NSString *)description{
    
    NSString *desc = [NSString stringWithFormat:
                      @"%@\
                      \n\tuserName:%@\
                      \n\tuserStatus:%@\
                      \n\tqbUserID:%u\
                      \n\tfbUser:%@\
                      \n\tgeoDataID:%d\
                      \n\tfbCheckinID:%@\
                      \n\tfbPlaceID:%@\
                      \n\tcreatedAt:%@",
                      
                      [super description],
                      userName,
                      userStatus,
                      qbUserID,
                      fbUser,
                      geoDataID,
                      fbCheckinID,
                      fbPlaceID,
                      createdAt];
    
    return desc;
}

#pragma mark -
#pragma mark NSCopying

-(id)copyWithZone:(NSZone *)zone
{
    UserAnnotation *copy = [[[self class] allocWithZone:zone] init];
    
    copy.userPhotoUrl       = [[self.userPhotoUrl copyWithZone:zone] autorelease];
    copy.userName           = [[self.userName copyWithZone:zone] autorelease];
    copy.userStatus         = [[self.userStatus copyWithZone:zone] autorelease];
    copy.coordinate         = self.coordinate;
    copy.createdAt          = [[self.createdAt copyWithZone:zone] autorelease];
    
    copy.fbUser             = [[self.fbUser copyWithZone:zone] autorelease];
    copy.fbUserId           = [[self.fbUserId copyWithZone:zone] autorelease];
    copy.geoDataID          = self.geoDataID;
    copy.fbCheckinID        = [[self.fbCheckinID copyWithZone:zone] autorelease];
    copy.fbPlaceID          = [[self.fbPlaceID copyWithZone:zone] autorelease];
    copy.qbUserID           = self.qbUserID;
    
    copy.distance           = self.distance;
    
    copy.quotedUserFBId     = [[self.quotedUserFBId copyWithZone:zone] autorelease];
    copy.quotedUserPhotoURL = [[self.quotedUserPhotoURL copyWithZone:zone] autorelease];
    copy.quotedUserName     = [[self.quotedUserName copyWithZone:zone] autorelease];
    copy.quotedMessageDate  = [[self.quotedMessageDate copyWithZone:zone] autorelease];
    copy.quotedMessageText  = [[self.quotedMessageText copyWithZone:zone] autorelease];
    
    return copy;
}

@end
