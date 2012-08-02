//
//  Checkin.h
//  Chattar
//
//  Created by IgorKh on 8/2/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Checkin : NSManagedObject

@property (nonatomic, retain) NSString * accountFBUserID;
@property (nonatomic, retain) id body;

@end
