//
//  QuickBloxDialogsDataSource.h
//  ChattAR
//
//  Created by Igor Alefirenko on 11/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuickBloxDialogsDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSMutableDictionary *conversation;

@end
