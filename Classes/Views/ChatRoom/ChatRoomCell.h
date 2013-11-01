//
//  ChatRoomCell.h
//  ChattAR
//
//  Created by Igor Alefirenko on 11/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ChatRoomCell : UITableViewCell

@property (nonatomic, strong) UIImageView *colorBuble;
@property (nonatomic, strong) UILabel *message;
@property (nonatomic, strong) UILabel *userName;
@property (nonatomic, strong) AsyncImageView *userPhoto;
@property (nonatomic, strong) UILabel *postMessageDate;
@property (nonatomic, strong) UIImage *bubleImage;
@property (nonatomic, strong) UILabel *distance;

- (void)handleParametersForCellWithQBMessage:(QBChatMessage *)message andIndexPath:(NSIndexPath *)indexPath;
- (void)handleParametersForCellWithFBMessage:(NSDictionary *)message andIndexPath:(NSIndexPath *)indexPath;
+ (CGFloat)configureHeightForCellWithMessage:(NSString *)msg;

@end
