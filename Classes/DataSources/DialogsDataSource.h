//
//  DialogsDataSource.h
//  ChattAR
//
//  Created by Igor Alefirenko on 28/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DialogsDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *otherUsers;

@end
