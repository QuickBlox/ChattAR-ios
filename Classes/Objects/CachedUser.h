//
//  ChachedUser.h
//  ChattAR
//
//  Created by Igor Alefirenko on 20/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CachedUser : NSObject {
    UIImage *userPhotography;
    NSString *userName;
    NSString *userMessage;
    NSString *dateTime;
}

@property (nonatomic, strong) UIImage *userPhotography;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userMessage;
@property (nonatomic, strong) NSString *dateTime;

@end
