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
@property (nonatomic, strong) NSArray *allChatRooms;
@property (strong, nonatomic) NSIndexPath *currentPath;

+(ChatRooms *)action;


#pragma mark -
#pragma mark Setter & Getter

-(void)setRooms:(NSArray *)rooms;
-(NSArray *)getAllRooms;

@end
