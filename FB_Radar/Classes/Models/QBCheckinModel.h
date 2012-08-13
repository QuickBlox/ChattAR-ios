//
//  QBCheckinModel.h
//  Chattar
//
//  Created by IgorKh on 8/10/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface QBCheckinModel : NSManagedObject

@property (nonatomic, retain) id body;
@property (nonatomic, retain) NSNumber * qbUserID;
@property (nonatomic, retain) NSNumber * timestamp;

@end
