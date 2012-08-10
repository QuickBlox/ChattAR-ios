//
//  ChatMessage.h
//  Chattar
//
//  Created by IgorKh on 8/10/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChatMessage : NSManagedObject

@property (nonatomic, retain) id body;
@property (nonatomic, retain) NSNumber * geoDataID;
@property (nonatomic, retain) NSNumber * timestamp;

@end
