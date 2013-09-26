//
//  QuotedChatRoomCell.m
//  ChattAR
//
//  Created by Igor Alefirenko on 20/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "QuotedChatRoomCell.h"


@implementation QuotedChatRoomCell

@synthesize qColorBuble = _qColorBuble;
@synthesize qDateTime = _qDateTime;
@synthesize qMessage = _qMessage;
@synthesize qUserName = _qUserName;
@synthesize qUserPhoto = _qUserPhoto;
@synthesize replyImg;

@synthesize rColorBuble = _rColorBuble;
@synthesize rDateTime = _rDateTime;
@synthesize rDistance =_rDistance;
@synthesize rMessage = _rMessage;
@synthesize rUserName = _rUserName;
@synthesize rUserPhoto = _rUserPhoto;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // quote:
        self.qColorBuble = [[UIImageView alloc] initWithFrame:CGRectMake(108, 10, 202, 70)];
        self.qColorBuble.image = [[UIImage imageNamed:@"01_grey_chat_bubble.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
        self.qUserPhoto = [[AsyncImageView alloc] initWithFrame:CGRectMake(63, 10, 40, 40)];
        self.qUserPhoto.image = [UIImage imageNamed:@"Icon@2x.png"];
        
        replyImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"05_reply_arrow-1.png"]];
        replyImg.frame = CGRectMake(58 - replyImg.image.size.width, 45- replyImg.image.size.height, replyImg.image.size.width, replyImg.frame.size.height);
        
        
        self.qUserName = [[UILabel alloc] initWithFrame:CGRectMake(128, 20, 132, 20)];
        self.qUserName.textColor = [UIColor darkGrayColor];
        self.qUserName.font = [UIFont boldSystemFontOfSize:18.0];
        self.qUserName.textAlignment = UITextAlignmentLeft;
        self.qUserName.backgroundColor = [UIColor clearColor];
        
        self.qMessage = [[UILabel alloc] initWithFrame:CGRectMake(128, 40, 182, 20)];
        self.qMessage.textColor = [UIColor darkGrayColor];
        self.qMessage.backgroundColor = [UIColor clearColor];
        self.qMessage.numberOfLines = 1;
        
        self.qDateTime = [[UILabel alloc] initWithFrame:CGRectMake(245.0f, 20.0f, 55.0f, 20.0f)];
        self.qDateTime.textAlignment = UITextAlignmentRight;
        self.qDateTime.textColor = [UIColor darkGrayColor];
        self.qDateTime.backgroundColor = [UIColor clearColor];
        self.qDateTime.font = [UIFont systemFontOfSize:13.0f];
        
        // reply:
        self.rDistance = [[UILabel alloc] initWithFrame:CGRectMake(10, 50+50, 50, 15)];
        self.rUserName = [[UILabel alloc] initWithFrame:CGRectMake(75, 20+50, 180, 20)];
        self.rMessage = [[UILabel alloc] init];
        self.rColorBuble = [[UIImageView alloc] init];
        self.rUserPhoto = [[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10+50, 40, 40)];
        self.rDateTime = [[UILabel alloc] initWithFrame:CGRectMake(245.0f, 20 + 50, 55.0f, 20.0f)];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.rMessage.textColor = [UIColor whiteColor];
        self.rMessage.backgroundColor = [UIColor clearColor];
        self.rMessage.numberOfLines = 0;
        
        self.rUserName.textColor = [UIColor whiteColor];
        self.rUserName.font = [UIFont boldSystemFontOfSize:18.0];
        self.rUserName.textAlignment = UITextAlignmentLeft;
        self.rUserName.backgroundColor = [UIColor clearColor];
        
        self.rDateTime.textAlignment = UITextAlignmentRight;
        self.rDateTime.textColor = [UIColor whiteColor];
        self.rDateTime.backgroundColor = [UIColor clearColor];
        self.rDateTime.font = [UIFont systemFontOfSize:13.0f];
        
        self.rDistance.font = [UIFont systemFontOfSize:11.0f];
        self.rDistance.textColor = [UIColor darkGrayColor];
        self.rDistance.backgroundColor = [UIColor clearColor];
        self.rDistance.textAlignment = UITextAlignmentLeft;
        
        // putting all subviews
        [self.contentView addSubview:qUserPhoto];
        [self.contentView addSubview:replyImg];
        [self.contentView addSubview:qColorBuble];
        [self.contentView addSubview:qUserName];
        [self.contentView addSubview:qMessage];
        [self.contentView addSubview:qDateTime];
        
        [self.contentView addSubview:rUserPhoto];
        [self.contentView addSubview:rDistance];
        [self.contentView addSubview:rColorBuble];
        [self.contentView addSubview:rUserName];
        [self.contentView addSubview:rMessage];
        [self.contentView addSubview:rDateTime];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
