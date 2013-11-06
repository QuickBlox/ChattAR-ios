//
//  MyPaginator.m
//  ChattAR
//
//  Created by Igor Alefirenko on 01/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "ChatRoomsPaginator.h"

@implementation ChatRoomsPaginator

- (void)fetchResultsWithPage:(NSInteger)page pageSize:(NSInteger)pageSize
{
    // records skiped
    NSInteger skipedRecords = (page - 1) * pageSize;
    
    NSMutableDictionary *extendedRequest = [NSMutableDictionary dictionary];
    [extendedRequest setValue:[NSNumber numberWithInteger:pageSize] forKey:kLimit];
    [extendedRequest setValue:[NSNumber numberWithInteger:skipedRecords] forKey:kSkip];
    [extendedRequest setValue:kRank forKey:kSortDesc];
    
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
