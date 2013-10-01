//
//  MyPaginator.m
//  ChattAR
//
//  Created by Igor Alefirenko on 01/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "MyPaginator.h"

@implementation MyPaginator

- (void)fetchResultsWithPage:(NSInteger)page pageSize:(NSInteger)pageSize
{
    // you code goes here
    // once you receive the results for the current page, just call [self receivedResults:results total:total];
    // records skiped
    NSInteger skipedRecords = (page - 1) * pageSize;
    
    NSMutableDictionary *extendedRequest = [NSMutableDictionary dictionary];
    [extendedRequest setValue:[NSNumber numberWithInteger:pageSize] forKey:@"limit"];
    [extendedRequest setValue:[NSNumber numberWithInteger:skipedRecords] forKey:@"skip"];
    [extendedRequest setValue:@"rank" forKey:@"sort_desc"];
    
    [QBCustomObjects objectsWithClassName:kChatRoom extendedRequest:extendedRequest delegate:self];
}

#pragma marak -
#pragma mark QBActionStatusDelegate

-(void)completedWithResult:(Result *)result{
    if ([result success]) {
        if ([result isKindOfClass:[QBCOCustomObjectPagedResult class]]) {
            // todo:
            QBCOCustomObjectPagedResult *pagedResult = (QBCOCustomObjectPagedResult *)result;
            NSArray *gettingRooms = pagedResult.objects;
            NSInteger roomsCount = 23;
            [self receivedResults:gettingRooms total:roomsCount];
            
        }
    }
}

@end
