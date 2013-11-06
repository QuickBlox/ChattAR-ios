//
//  CAnotationView.m
//  ChattAR
//
//  Created by Igor Alefirenko on 07/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "CAnotationView.h"

@implementation CAnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.avatar = [[UIImageView alloc] initWithFrame:CGRectMake(11, 13, 40, 40)];
        [self addSubview:_avatar];
    }
    return self;
}

@end
