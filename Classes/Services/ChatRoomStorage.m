//
//  ChatRooms.m
//  ChattAR
//
//  Created by Igor Alefirenko on 30/09/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "ChatRoomStorage.h"
#import "LocationService.h"


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
    
    NSString *myLatitude = [[NSString alloc] initWithFormat:@"%f",[[LocationService shared] getMyCoorinates].latitude];
    NSString *myLongitude = [[NSString alloc] initWithFormat:@"%f", [[LocationService shared] getMyCoorinates].longitude];
    
    [QBContent TUploadFile:imageData fileName:name contentType:@"image/jpg" isPublic:YES delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:^(Result *result) {
        // Upload file result
        if(result.success && [result isKindOfClass:[QBCFileUploadTaskResult class]]){
            // File uploaded, do something
            QBCBlob *uploadedFile  = ((QBCFileUploadTaskResult *)result).uploadedBlob;
            // File public url. Will be null if isPublic:NO in query
            NSString *fileUrl = [uploadedFile publicUrl];
            object.fields[kPhoto] = fileUrl;
            
            [QBCustomObjects createObject:object delegate:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:CAChatRoomDidCreateNotification object:object];
            
        }else{
            NSLog(@"errors=%@", result.errors);
        }
    }]];
    
    object.fields[kLatitude] = myLatitude;
    object.fields[kLongitude] = myLongitude;
    object.fields[kName] = name;
    object.fields[kRank] = [NSNumber numberWithInt:1];
}

#pragma mark -
#pragma mark Options

- (NSMutableArray *)sortingRoomsByDistance:(CLLocation *)me toChatRooms:(NSArray *)rooms {
    NSArray *sortedRooms = [rooms sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CLLocation *room1 = [[CLLocation alloc] initWithLatitude:[[[obj1 fields] objectForKey:kLatitude] doubleValue] longitude:[[[obj1 fields] objectForKey:kLongitude] doubleValue]];
        CLLocation *room2 = [[CLLocation alloc] initWithLatitude:[[[obj2 fields] objectForKey:kLatitude] doubleValue] longitude:[[[obj2 fields] objectForKey:kLongitude] doubleValue]];
        NSInteger distance1 = [me distanceFromLocation:room1];
        NSInteger distance2 = [me distanceFromLocation:room2];
        
        if ( distance1 < distance2) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ( distance1 > distance2) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
        
    }];
    NSMutableArray *neibRooms = [NSMutableArray array];
    for (int i=0; i<30; i++) {
        if ([sortedRooms objectAtIndex:i] != [sortedRooms lastObject]) {
            [neibRooms addObject:[sortedRooms objectAtIndex:i]];
        } else {
            [neibRooms addObject:[sortedRooms objectAtIndex:i]];
            break;
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


#pragma mark -
#pragma mark QBActionStatusDelegate

- (void)completedWithResult:(Result *)result {
    if ([result success]) {
        if ([result isKindOfClass:[QBCOCustomObjectPagedResult class]]) {
            QBCOCustomObjectPagedResult *pagedResult = (QBCOCustomObjectPagedResult *)result;
            NSArray *searchedRooms = pagedResult.objects;
            self.searchedRooms = searchedRooms;
            [[NSNotificationCenter defaultCenter] postNotificationName:CAChatDidReceiveSearchResults object:nil];
        }
    }
}

@end
