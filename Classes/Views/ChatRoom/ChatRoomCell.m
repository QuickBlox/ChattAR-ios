//
//  ChatRoomCell.m
//  ChattAR
//
//  Created by Igor Alefirenko on 11/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "ChatRoomCell.h"
#import "LocationService.h"
#import "Utilites.h"
#import "FBStorage.h"

@implementation ChatRoomCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.userPhoto = [[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [self.contentView addSubview:self.userPhoto];
        
        self.colorBuble = [[UIImageView alloc] init];
        [self.contentView addSubview:self.colorBuble];
        
        self.message = [[UILabel alloc] init];
        self.message.textColor = [UIColor whiteColor];
        self.message.backgroundColor = [UIColor clearColor];
        self.message.numberOfLines = 0;
        [self.contentView addSubview:self.message];
        
        self.userName = [[UILabel alloc] initWithFrame:CGRectMake(75, 20, 180, 20)];
        self.userName.textColor = [UIColor whiteColor];
        self.userName.font = [UIFont boldSystemFontOfSize:18.0];
        self.userName.textAlignment = UITextAlignmentLeft;
        self.userName.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.userName];
        // date time of message
        self.postMessageDate = [[UILabel alloc] initWithFrame:CGRectMake(245.0f, 20.0f, 55.0f, 20.0f)];
        self.postMessageDate.textAlignment = UITextAlignmentRight;
        self.postMessageDate.textColor = [UIColor whiteColor];
        self.postMessageDate.backgroundColor = [UIColor clearColor];
        self.postMessageDate.font = [UIFont systemFontOfSize:13.0f];
        [self.contentView addSubview:self.postMessageDate];
        
        // Distance to user label
        self.distance = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 50, 15)];
        self.distance.font = [UIFont systemFontOfSize:11.0f];
        self.distance.textColor = [UIColor darkGrayColor];
        self.distance.backgroundColor = [UIColor clearColor];
        self.distance.textAlignment = UITextAlignmentLeft;
        [self.contentView addSubview:self.distance];
        // set selection style: none
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

// HANDLE CELL FOR QB MESSAGE:
- (void)handleParametersForCellWithQBMessage:(QBChatMessage *)message andIndexPath:(NSIndexPath *)indexPath{
    // Buble
    if ([indexPath row] % 2 == 0) {
        self.bubleImage = [[UIImage imageNamed:@"01_green_chat_bubble.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    } else {
        self.bubleImage = [[UIImage imageNamed:@"01_blue_chat_bubble.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    }
    self.colorBuble.image = self.bubleImage;
    
    // user message

    // getting dictionary from JSON
    NSData *dictData = [message.text dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *tempDict = [NSJSONSerialization JSONObjectWithData:dictData options:NSJSONReadingAllowFragments error:nil];
    
    //getting Avatar from url
    NSString *urlString = [tempDict objectForKey:kUserPhotoUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    
    //getting location of a message sender
    CGFloat latitude = [[tempDict objectForKey:kLatitude] floatValue];
    CGFloat longitude = [[tempDict objectForKey:kLongitude] floatValue];
    CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    CLLocationDistance distanceToMe = [[LocationService shared].myLocation distanceFromLocation:userLocation];
    
    // post message date
    
    NSString *time = [[Utilites shared].dateFormatter stringFromDate:message.datetime];
    
    // putting data to fields
    [self.userPhoto setImageURL:url];
    self.distance.text = [[Utilites shared] distanceFormatter:distanceToMe];
    self.message.text = [tempDict objectForKey:kMessage];
    self.userName.text = [tempDict objectForKey:kUserName];
    self.postMessageDate.text = time;
    
    
    //changing hight
    CGSize textSize = { 225.0, 10000.0 };
    CGSize size = [[self.message text] sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    [self.message setFrame:CGRectMake(75, 43, 225, size.height)];
    [self.colorBuble setFrame:CGRectMake(55, 10, 255, size.height+padding*2)];
}

// HANDLE CELL FOR FB MESSAGE
- (void)handleParametersForCellWithFBMessage:(NSDictionary *)message andIndexPath:(NSIndexPath *)indexPath {
    // Buble
    if ([indexPath row] % 2 == 0) {
        self.bubleImage = [[UIImage imageNamed:@"01_green_chat_bubble.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    } else {
        self.bubleImage = [[UIImage imageNamed:@"01_blue_chat_bubble.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    }
    self.colorBuble.image = self.bubleImage;
    
    // user message
    NSString *userMessage = [message objectForKey:kMessage];
    //getting Avatar from url
    NSString *friendID = [[message objectForKey:kFrom] objectForKey:kId];
    NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", friendID, [FBStorage shared].accessToken];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // post message date
    NSString *date = [message objectForKey:kCreatedTime];
    [[Utilites shared].dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
	NSDate *timeStamp = [[Utilites shared].dateFormatter dateFromString:date];
    [[Utilites shared].dateFormatter setDateFormat:@"HH:mm"];
    NSString *time = [[Utilites shared].dateFormatter stringFromDate:timeStamp];
    
    // putting data to fields
    [self.userPhoto setImageURL:url];
    self.message.text = userMessage;
    self.userName.text = [[message objectForKey:kFrom] objectForKey:kName];
    self.postMessageDate.text = time;
    
    
    //changing hight
    CGSize textSize = { 225.0, 10000.0 };
    CGSize size = [[self.message text] sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    [self.message setFrame:CGRectMake(75, 43, 225, size.height)];
    [self.colorBuble setFrame:CGRectMake(55, 10, 255, size.height+padding*2)];
}

+ (CGFloat)configureHeightForCellWithMessage:(NSString *)msg {
    CGSize textSize = { 225.0, 10000.0 };
    //changing hight
    CGSize size = [msg sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    size.height += padding*2;
    return size.height+10.0f;
}

@end
