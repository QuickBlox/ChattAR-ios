//
//  ProfileCell.m
//  ChattAR
//
//  Created by Igor Alefirenko on 06/12/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "ProfileCell.h"

@implementation ProfileCell

- (void)handleCellWithContent:(NSDictionary *)content {
    if (content[@"location"]) {
        [self.ProfileImage setImage:[UIImage imageNamed:@"001_location.png"]];
        [self.profileText setText:content[@"location"]];
    } else if (content[@"education"]) {
        [self.ProfileImage setImage:[UIImage imageNamed:@"001_education.png"]];
        [self.profileText setText:content[@"education"]];
    } else if (content[@"work"]) {
        [self.ProfileImage setImage:[UIImage imageNamed:@"001_work.png"]];
        [self.profileText setText:content[@"work"]];
    }
}

@end
