//
//  UserAnnotation.m
//  Fbmsg
//
//  Created by Igor Khomenko on 3/28/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "UserAnnotation.h"
#import "Macro.h"

@implementation UserAnnotation
@synthesize userPhotoUrl, userName, userStatus, coordinate, fbUserId, geoDataID, createdAt, fbUser, quotedUserName, quotedMessageDate, quotedMessageText, quotedUserPhotoURL, distance, quotedUserFBId, quotedUserQBId, qbUserID, fbCheckinID;

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
    
    [super dealloc];
}

- (NSString *)description{
    
    NSString *desc = [NSString stringWithFormat:
                      @"%@\
                      \n\tuserName:%@\
                      \n\tuserStatus:%@\
                      \n\tfbUserId:%@\
                      \n\tqbUserID:%u\
                      \n\tfbUser:%@\
                      \n\tcreatedAt:%@",
                      
                      [super description],
                      userName,
                      userStatus,
                      fbUserId,
                      qbUserID,
                      fbUser,
                      createdAt];
    
    return desc;
}


@end
