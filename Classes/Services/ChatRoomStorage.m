//
//  ChatRooms.m
//  ChattAR
//
//  Created by Igor Alefirenko on 30/09/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "ChatRoomStorage.h"
#import "LocationService.h"
#import "ProcessStateService.h"
#import "FBStorage.h"
#import "QBStorage.h"

@interface ChatRoomStorage()

@end


@implementation ChatRoomStorage 

+ (instancetype)shared {
    static id sharedChatRoomsService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedChatRoomsService = [[self alloc] init];
    });
    return sharedChatRoomsService;
}


#pragma mark -
#pragma mark Create room

- (void)createChatRoomWithName:(NSString *)name imageData:(NSData *)imageData {
    QBCOCustomObject *object = [QBCOCustomObject customObject];
    object.className = kChatRoom;
    
    CLLocationCoordinate2D locate = [LocationService shared].myLocation.coordinate;
    NSString *myLatitude = [@(locate.latitude) stringValue];
    NSString *myLongitude = [@(locate.longitude) stringValue];

    object.fields[kLatitude] = myLatitude;
    object.fields[kLongitude] = myLongitude;
    object.fields[kName] = name;
    object.fields[kRank] = @1;
    
    if (imageData != nil) {
        [QBContent TUploadFile:imageData fileName:name contentType:@"image/jpg" isPublic:YES delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:^(Result *result) {
            // Upload file result
            if(result.success && [result isKindOfClass:[QBCFileUploadTaskResult class]]){
                // File uploaded, do something
                QBCBlob *uploadedFile  = ((QBCFileUploadTaskResult *)result).uploadedBlob;
                // File public url. Will be null if isPublic:NO in query
                NSString *fileUrl = [uploadedFile publicUrl];
                object.fields[kPhoto] = fileUrl;
                
                [QBCustomObjects createObject:object delegate:nil];
                [Flurry logEvent:kFlurryEventNewRoomWasCreated withParameters:@{kName:object.fields[kName], @"avatar":@"Yes"}];
                [[NSNotificationCenter defaultCenter] postNotificationName:CAChatRoomDidCreateNotification object:object];
                
            }else{
                NSLog(@"errors=%@", result.errors);
            }
        }]];
    } else {
        [QBCustomObjects createObject:object delegate:nil];
        [Flurry logEvent:kFlurryEventNewRoomWasCreated withParameters:@{kName:object.fields[kName], @"avatar":@"No"}];
        [[NSNotificationCenter defaultCenter] postNotificationName:CAChatRoomDidCreateNotification object:object];
    }
}


#pragma mark -
#pragma mark Options

- (NSMutableArray *)sortRooms:(NSArray *)rooms accordingToLocation:(CLLocation *)location limit:(NSUInteger)limit
{
    NSArray *sortedRooms = [rooms sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        // first location
        double_t latitude = [[[obj1 fields] objectForKey:kLatitude] doubleValue];
        double_t longitude = [[[obj1 fields] objectForKey:kLongitude] doubleValue];
        CLLocation *room1 = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        // second location
        latitude = [[[obj2 fields] objectForKey:kLatitude] doubleValue];
        longitude = [[[obj2 fields] objectForKey:kLongitude] doubleValue];
        CLLocation *room2 = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        // distances to both locations:
        NSInteger distance1 = [location distanceFromLocation:room1];
        NSInteger distance2 = [location distanceFromLocation:room2];
        
        if ( distance1 < distance2) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ( distance1 > distance2) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
    
    NSMutableArray *neibRooms = [NSMutableArray array];
    
    if(sortedRooms.count < limit){
        [neibRooms addObjectsFromArray:sortedRooms];
    }else{
        for (int i=0; i<limit; i++) {
            [neibRooms addObject:[sortedRooms objectAtIndex:i]];
        }
    }
    
    return neibRooms;
}

- (void)increaseRankOfRoom:(QBCOCustomObject *)room {
    NSNumber *numb = room.fields[kRank];
    NSInteger rank = [numb integerValue];
    rank++;
    room.fields[kRank] = [NSNumber numberWithInteger:rank];
    
    QBCOCustomObject *newRoom = [QBCOCustomObject customObject];
    newRoom.className = room.className;
    newRoom.ID = room.ID;
    [QBCustomObjects updateObject:newRoom specialUpdateOperators:[@{@"inc[rank]" : @(1)} mutableCopy] delegate:nil];
}

- (QBCOCustomObject *)findChatRoomWithName:(NSString *)roomName
{
    for (QBCOCustomObject *room in self.trendingRooms) {
        if ([room.fields[kName] isEqual:roomName]) {
            return room;
        }
    }
    for (QBCOCustomObject *room in self.localRooms) {
        if ([room.fields[kName] isEqual:roomName]) {
            return room;
        }
    }
    return nil;
}

- (int)trackAllUnreadMessages
{
    int unreadMsgCount = 0;
    NSArray *allFacebookConversations = [[FBStorage shared].allFriendsHistoryConversation allValues];
    for (NSMutableDictionary *conversation in allFacebookConversations) {
        unreadMsgCount += [conversation[kUnread] integerValue];
    }
    
    NSArray *allQuickbloxConversations = [[QBStorage shared].allQuickBloxHistoryConversation allValues];
    for (NSMutableDictionary *conversation in allQuickbloxConversations) {
        unreadMsgCount += [conversation[kUnread] integerValue];
    }
    return unreadMsgCount;
}

@end
