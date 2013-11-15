//
//  QBChatMessage+Serialization.h
//  ChattAR
//
//  Created by Igor Alefirenko on 13/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Quickblox/Quickblox.h>

@interface QBChatMessage (Serialization)

- (NSString *)quickbloxUserID;
- (NSString *)facebookUserID;

@end
