//
//  QBRDeleteScoreByIDQuery.h
//  Quickblox
//
//  Created by Alexander Chaika on 06.04.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBRDeleteScoreByIDQuery : QBRatingsServiceQuery {
    NSUInteger scoreId;
}

@property (nonatomic, assign) NSUInteger scoreId;

@end
