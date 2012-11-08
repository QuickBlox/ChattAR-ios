//
//  QBChatMessageModel.h
//  ChattAR for facebook
//
//  Created by QuickBlox developers on 8/10/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface QBChatMessageModel : NSManagedObject

@property (nonatomic, retain) id body;
@property (nonatomic, retain) NSNumber * geoDataID;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString *fbUserID;

@end
