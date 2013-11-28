//
//  QuickBloxDialogsDataSource.h
//  ChattAR
//
//  Created by Igor Alefirenko on 11/11/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NonFriendDialogDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSMutableDictionary *conversation;

@end
