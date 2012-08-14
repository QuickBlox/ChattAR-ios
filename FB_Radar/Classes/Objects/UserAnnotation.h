//
//  UserAnnotation.h
//  Fbmsg
//
//  Created by Igor Khomenko on 3/28/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Map Annotation class */
@interface UserAnnotation : NSObject <MKAnnotation, NSCoding>{
    NSString *userPhotoUrl;
    NSString *userName;
    NSString *userStatus;
    CLLocationCoordinate2D coordinate;
    NSDate *createdAt;
    
    NSDictionary *fbUser;
    NSString *fbUserId;
    NSUInteger geoDataID;
    NSString *fbCheckinID;
    NSUInteger qbUserID;
    
    NSInteger distance;
    
    // quote
    NSString* quotedUserFBId;
    NSString* quotedUserPhotoURL;
    NSString* quotedUserName;
    NSDate* quotedMessageDate;
    NSString* quotedMessageText;
}

@property (nonatomic, retain) NSString *userPhotoUrl;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *userStatus;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSDate *createdAt;

@property (nonatomic, retain) NSDictionary *fbUser;
@property (nonatomic, retain) NSString *fbUserId;
@property (nonatomic, assign) NSUInteger geoDataID;
@property (nonatomic, retain) NSString *fbCheckinID;
@property (nonatomic, assign) NSUInteger qbUserID;

@property (nonatomic, assign) NSInteger distance;

// quote
@property (nonatomic, retain) NSString* quotedUserFBId;
@property (nonatomic, retain) NSString* quotedUserQBId;
@property (nonatomic, retain) NSString* quotedUserPhotoURL;
@property (nonatomic, retain) NSString* quotedUserName;
@property (nonatomic, retain) NSDate* quotedMessageDate;
@property (nonatomic, retain) NSString* quotedMessageText;

@end
