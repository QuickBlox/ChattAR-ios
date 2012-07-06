//
//  FBServiceResult.h
//  FB_Radar
//
//  Created by Sonny Black on 07.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBServiceResult : NSObject

@property (nonatomic, retain) NSDictionary		*body;
@property (nonatomic) FBQueriesTypes			queryType;
@property (nonatomic, retain) NSString			*context;

@end
