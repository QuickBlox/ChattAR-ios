//
//  QuotedChatRoomCell.m
//  ChattAR
//
//  Created by Igor Alefirenko on 20/09/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "QuotedChatRoomCell.h"
#import "LocationService.h"
#import "FBStorage.h"
#import "Utilites.h"


@implementation QuotedChatRoomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // QUOTE:
        // Quote message buble: (Default: grey)
        self.qColorBuble = [[UIImageView alloc] initWithFrame:CGRectMake(108, 10, 202, 70)];
        self.qColorBuble.image = [[UIImage imageNamed:@"01_grey_chat_bubble.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
        [self.contentView addSubview:self.qColorBuble];
        
        self.qUserPhoto = [[AsyncImageView alloc] initWithFrame:CGRectMake(63, 10, 40, 40)];
        self.qUserPhoto.image = [UIImage imageNamed:@"Icon@2x.png"];
        self.qUserPhoto.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.qUserPhoto];
        // reply arrow
        self.replyImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"05_reply_arrow-1.png"]];
        self.replyImg.frame = CGRectMake(58 - self.replyImg.image.size.width, 45- self.replyImg.image.size.height, self.replyImg.image.size.width, self.replyImg.frame.size.height);
        [self.contentView addSubview:self.replyImg];
        
        self.qUserName = [[UILabel alloc] initWithFrame:CGRectMake(128, 20, 132, 20)];
        self.qUserName.textColor = [UIColor darkGrayColor];
        self.qUserName.font = [UIFont boldSystemFontOfSize:18.0];
        self.qUserName.textAlignment = UITextAlignmentLeft;
        self.qUserName.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.qUserName];
        
        self.qMessage = [[UILabel alloc] initWithFrame:CGRectMake(128, 40, 182, 20)];
        self.qMessage.textColor = [UIColor darkGrayColor];
        self.qMessage.backgroundColor = [UIColor clearColor];
        self.qMessage.numberOfLines = 1;
        [self.contentView addSubview:self.qMessage];
        
        self.qDateTime = [[UILabel alloc] initWithFrame:CGRectMake(245.0f, 20.0f, 55.0f, 20.0f)];
        self.qDateTime.textAlignment = UITextAlignmentRight;
        self.qDateTime.textColor = [UIColor darkGrayColor];
        self.qDateTime.backgroundColor = [UIColor clearColor];
        self.qDateTime.font = [UIFont systemFontOfSize:13.0f];
        [self.contentView addSubview:self.qDateTime];
        
        // REPLY:
        self.rUserPhoto = [[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10+50, 40, 40)];
        [self.contentView addSubview:self.rUserPhoto];
        // distance to me label
        self.rDistance = [[UILabel alloc] initWithFrame:CGRectMake(10, 50+50, 50, 15)];
        self.rDistance.font = [UIFont systemFontOfSize:11.0f];
        self.rDistance.textColor = [UIColor darkGrayColor];
        self.rDistance.backgroundColor = [UIColor clearColor];
        self.rDistance.textAlignment = UITextAlignmentLeft;
        [self.contentView addSubview:self.rDistance];
        // Reply message buble:(Blue or Green)
        self.rColorBuble = [[UIImageView alloc] init];
        [self.contentView addSubview:self.rColorBuble];
        
        self.rUserName = [[UILabel alloc] initWithFrame:CGRectMake(75, 20+50, 180, 20)];
        self.rUserName.textColor = [UIColor whiteColor];
        self.rUserName.font = [UIFont boldSystemFontOfSize:18.0];
        self.rUserName.textAlignment = UITextAlignmentLeft;
        self.rUserName.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.rUserName];
        
        self.rMessage = [[UILabel alloc] init];
        self.rMessage.textColor = [UIColor whiteColor];
        self.rMessage.backgroundColor = [UIColor clearColor];
        self.rMessage.numberOfLines = 0;
        [self.contentView addSubview:self.rMessage];
        
        self.rDateTime = [[UILabel alloc] initWithFrame:CGRectMake(245.0f, 20 + 50, 55.0f, 20.0f)];
        self.rDateTime.textAlignment = UITextAlignmentRight;
        self.rDateTime.textColor = [UIColor whiteColor];
        self.rDateTime.backgroundColor = [UIColor clearColor];
        self.rDateTime.font = [UIFont systemFontOfSize:13.0f];
        [self.contentView addSubview:self.rDateTime];
        
        // set selection style: none
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)handleParametersForCellWithMessage:(QBChatMessage *)message andIndexPath:(NSIndexPath *)indexPath {

    UIImage *defaultImage = [UIImage imageNamed:@"human.png"];
    [self.qUserPhoto setImage:defaultImage];
    [self.rUserPhoto setImage:defaultImage];
    
    NSData *data = [message.text dataUsingEncoding:NSUTF8StringEncoding];
    // parsing JSON to dictionary
    NSDictionary *quoteDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    // getting quote from message
    NSDictionary *quoted = [quoteDict objectForKey:kQuote];
    
    //QUOTE:
    //getting Avatar from url
    NSString *urlString = [quoted objectForKey:kPhoto];
    NSURL *url = [NSURL URLWithString:urlString];
    [self.qUserPhoto setImageURL:url];
    // getting data from dictionary
    self.qUserName.text = [quoted objectForKey:kUserName];
    self.qMessage.text = [quoted objectForKey:kMessage];
    self.qDateTime.text = [quoted objectForKey:kDateTime];
    
    // REPLY:
    // getting avatar url
    NSString *uStr = [quoteDict objectForKey:kPhoto];
    NSURL *urlImg = [NSURL URLWithString:uStr];
    
    // date formatter
    NSString *time = [[Utilites shared] fullFormatPassedTimeFromDate:message.datetime];
    
    // getting location
    double_t latutude = [quoteDict[kLatitude] doubleValue];
    double_t longitude = [quoteDict[kLongitude] doubleValue];
    CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:latutude longitude:longitude];
    CLLocationDistance distanceToMe = [[LocationService shared].myLocation distanceFromLocation:userLocation];
    NSString *distance = [[Utilites shared] distanceFormatter:distanceToMe];
    
    //changing hight
    CGSize textSize = { 225.0, 10000.0 };
    CGSize size = [[quoteDict objectForKey:kMessage] sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    [self.rMessage setFrame:CGRectMake(75, 43+50, 225, size.height)];
    [self.rColorBuble setFrame:CGRectMake(55, 10+50, 255, size.height+padding*2)];
    
    [self.rUserPhoto setImageURL:urlImg];
    self.rUserName.text = [quoteDict objectForKey:kUserName];
    self.rMessage.text = [quoteDict objectForKey:kMessage];
    self.rDateTime.text = time;
    self.rDistance.text = distance;
}

+ (CGFloat)configureHeightForCellWithDictionary:(NSString *)msg {
    CGSize textSize = { 225.0, 10000.0 };
    //changing hight
    CGSize size = [msg sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    size.height += padding*2;
    return size.height + 10.0f + 50;
}

- (void)bubleImageForChatRoomWithUserID:(NSString *)currentID {
    UIImage *bubleImage = nil;
    if ([currentID isEqual:[FBStorage shared].me[kId]] || [[FBStorage shared] isFacebookFriendWithID:currentID]) {
        bubleImage = [[UIImage imageNamed:@"blue_bubble.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    } else {
        bubleImage = [[UIImage imageNamed:@"green_bubble.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    }
    self.rColorBuble.image =bubleImage;
}

@end
