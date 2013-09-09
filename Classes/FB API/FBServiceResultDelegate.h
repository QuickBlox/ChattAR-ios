//
//  FBServiceResultDelegate.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 07.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "FBServiceResult.h"

@protocol FBServiceResultDelegate <NSObject>

@optional
-(void)completedWithFBResult:(FBServiceResult *)result;
-(void)completedWithFBResult:(FBServiceResult *)result context:(id)context;


@end


