//
//  ChatRooms.h
//  ChattAR
//
//  Created by Igor Alefirenko on 30/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatRooms : NSObject {
    NSArray *allChatRooms;
    NSIndexPath *currentPath;
}
@property (nonatomic, strong) NSArray *allTrendingRooms;
@property (nonatomic, strong) NSArray *allLocalRooms;
@property (strong, nonatomic) NSIndexPath *currentPath;
@property (assign, nonatomic) NSInteger tableViewTag;

+(ChatRooms *)action;


#pragma mark -
#pragma mark Setter & Getter

-(void)setTrendingRooms:(NSArray *)rooms;
-(void)setLocalRooms:(NSArray *)rooms;

-(NSArray *)getTrendingRooms;
-(NSArray *)getLocalRooms;

@end
