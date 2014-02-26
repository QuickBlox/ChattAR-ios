//
//  ProfileCell.h
//  ChattAR
//
//  Created by Igor Alefirenko on 06/12/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *ProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *profileText;

- (void)handleCellWithContent:(NSDictionary *)content;

@end
