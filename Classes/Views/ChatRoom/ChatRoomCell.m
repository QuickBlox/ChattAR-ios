//
//  ChatRoomCell.m
//  ChattAR
//
//  Created by Igor Alefirenko on 11/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "ChatRoomCell.h"

@implementation ChatRoomCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.distance = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 50, 15)];
        self.userName = [[UILabel alloc] initWithFrame:CGRectMake(75, 20, 180, 20)];
        self.message = [[UILabel alloc] init];
        self.colorBuble = [[UIImageView alloc] init];
        self.userPhoto = [[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        self.postMessageDate = [[UILabel alloc] initWithFrame:CGRectMake(245.0f, 20.0f, 55.0f, 20.0f)];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.message.textColor = [UIColor whiteColor];
        self.message.backgroundColor = [UIColor clearColor];
        self.message.numberOfLines = 0;
        
        self.userName.textColor = [UIColor whiteColor];
        self.userName.font = [UIFont boldSystemFontOfSize:18.0];
        self.userName.textAlignment = UITextAlignmentLeft;
        self.userName.backgroundColor = [UIColor clearColor];
        
        self.postMessageDate.textAlignment = UITextAlignmentRight;
        self.postMessageDate.textColor = [UIColor whiteColor];
        self.postMessageDate.backgroundColor = [UIColor clearColor];
        self.postMessageDate.font = [UIFont systemFontOfSize:13.0f];
        
        self.distance.font = [UIFont systemFontOfSize:11.0f];
        self.distance.textColor = [UIColor darkGrayColor];
        self.distance.backgroundColor = [UIColor clearColor];
        self.distance.textAlignment = UITextAlignmentLeft;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
