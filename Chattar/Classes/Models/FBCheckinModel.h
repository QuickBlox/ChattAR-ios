//
//  FBCheckinModel.h
//  ChattAR for facebook
//
//  Created by QuickBlox developers on 8/2/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FBCheckinModel : NSManagedObject

@property (nonatomic, retain) NSString * accountFBUserID;
@property (nonatomic, retain) id body;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString * checkinID;
@property (nonatomic, retain) NSString * placeID;
@property (nonatomic, retain) NSString * fbUserID;

@end
