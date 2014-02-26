//
//  FacebookDialogsDataSource.h
//  ChattAR
//
//  Created by Igor Alefirenko on 12/11/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendDialogDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSMutableDictionary *conversation;

@end
