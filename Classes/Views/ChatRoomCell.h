//
//  ChatRoomCell.h
//  ChattAR
//
//  Created by Igor Alefirenko on 11/09/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ChatRoomCell : UITableViewCell

@property (nonatomic, strong) UIImageView *colorBuble;
@property (nonatomic, strong) UILabel *message;
@property (nonatomic, strong) UILabel *userName;
@property (nonatomic, strong) AsyncImageView *userPhoto;
@property (nonatomic, strong) UILabel *postMessageDate;
@property (nonatomic, strong) UIImage *bubleImage;       // unuseful
@property (nonatomic, strong) UILabel *distance;

- (void)handleParametersForCellWithQBMessage:(QBChatMessage *)message andIndexPath:(NSIndexPath *)indexPath;
- (void)handleParametersForCellWithFBMessage:(NSDictionary *)message andIndexPath:(NSIndexPath *)indexPath;
+ (CGFloat)configureHeightForCellWithMessage:(NSString *)msg;


#pragma mark -
#pragma mark Drawing bubles

- (void)bubleImageForChatRoomWithUserID:(NSString *)currentID;
- (void)bubleImageForDialogWithUserID:(NSString *)currentID;

@end
