//
//  MyPaginator.h
//  ChattAR
//
//  Created by Igor Alefirenko on 01/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "NMPaginator.h"

@interface ChatRoomsPaginator : NMPaginator <QBActionStatusDelegate>

@property (assign, nonatomic) NSInteger tag;

@end
