//
//  MyPaginator.m
//  ChattAR
//
//  Created by Igor Alefirenko on 01/10/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "ChatRoomsPaginator.h"

@implementation ChatRoomsPaginator

- (void)fetchResultsWithPage:(NSInteger)page pageSize:(NSInteger)pageSize
{
    // records skiped
    NSInteger skipedRecords = (page - 1) * pageSize;
    
    NSMutableDictionary *extendedRequest = [NSMutableDictionary dictionary];
    [extendedRequest setObject:[NSNumber numberWithInteger:pageSize] forKey:kLimit];
    [extendedRequest setObject:[NSNumber numberWithInteger:skipedRecords] forKey:kSkip];
    [extendedRequest setObject:kRank forKey:kSortDesc];
    [extendedRequest setObject:@"name,rank,latitude,longitude,photo" forKey:@"output"];
    
    [QBCustomObjects objectsWithClassName:kChatRoom extendedRequest:extendedRequest delegate:self];
}


#pragma marak -
#pragma mark QBActionStatusDelegate

- (void)completedWithResult:(Result *)result {
    if ([result success]) {
        if ([result isKindOfClass:[QBCOCustomObjectPagedResult class]]) {
            // todo:
            QBCOCustomObjectPagedResult *pagedResult = (QBCOCustomObjectPagedResult *)result;
            NSInteger roomsCount = 100000;
            [self receivedResults:pagedResult.objects total:roomsCount];
        }
    }
}


@end
