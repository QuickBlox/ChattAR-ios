//
//  FBServiceResult.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 07.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBServiceResult : NSObject

@property (nonatomic, retain) NSDictionary		*body;
@property (nonatomic) FBQueriesTypes			queryType;
@property (nonatomic, retain) NSString			*context;

@end
