//
//  ChatRoomCell.m
//  ChattAR
//
//  Created by Igor Alefirenko on 11/09/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "ChatRoomCell.h"
#import "LocationService.h"
#import "Utilites.h"
#import "FBStorage.h"

@implementation ChatRoomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.userPhoto = [[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [self.contentView addSubview:self.userPhoto];
        
        self.colorBuble = [[UIImageView alloc] init];
        [self.contentView addSubview:self.colorBuble];
        
        self.message = [[UILabel alloc] init];
        self.message.textColor = [UIColor whiteColor];
        self.message.backgroundColor = [UIColor clearColor];
        self.message.font = [UIFont systemFontOfSize:15.0f];
        self.message.numberOfLines = 0;
        [self.contentView addSubview:self.message];
        
        self.userName = [[UILabel alloc] initWithFrame:CGRectMake(75, 20, 155, 20)];
        self.userName.textColor = [UIColor whiteColor];
        self.userName.font = [UIFont boldSystemFontOfSize:16.0];
        self.userName.textAlignment = NSTextAlignmentLeft;
        self.userName.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.userName];
        // date time of message
        self.postMessageDate = [[UILabel alloc] initWithFrame:CGRectMake(235.0f, 20.0f, 65.0f, 20.0f)];
        self.postMessageDate.textAlignment = NSTextAlignmentRight;
        self.postMessageDate.textColor = [UIColor whiteColor];
        self.postMessageDate.backgroundColor = [UIColor clearColor];
        self.postMessageDate.font = [UIFont systemFontOfSize:10.0f];
        [self.contentView addSubview:self.postMessageDate];
        
        // Distance to user label
        self.distance = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 50, 15)];
        self.distance.font = [UIFont systemFontOfSize:11.0f];
        self.distance.textColor = [UIColor darkGrayColor];
        self.distance.backgroundColor = [UIColor clearColor];
        self.distance.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.distance];
        // set selection style: none
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

// HANDLE CELL FOR QB MESSAGE:
- (void)handleParametersForCellWithQBMessage:(QBChatMessage *)message andIndexPath:(NSIndexPath *)indexPath {
    
    [self.userPhoto setImage:[UIImage imageNamed:@"human.png"]];

    // getting dictionary from JSON
    NSData *dictData = [message.text dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *tempDict = [NSJSONSerialization JSONObjectWithData:dictData options:NSJSONReadingAllowFragments error:nil];
    
    //getting Avatar from url
    NSString *urlString = [tempDict objectForKey:kPhoto];
    NSURL *url = [NSURL URLWithString:urlString];
    
    //getting location of a message sender
    if (tempDict[kLatitude] != nil || tempDict[kLongitude] != nil) {
        double_t latitude = [tempDict[kLatitude] doubleValue];
        double_t longitude = [tempDict[kLongitude] doubleValue];
        CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        CLLocationDistance distanceToMe = [[LocationService shared].myLocation distanceFromLocation:userLocation];
        self.distance.text = [[Utilites shared] distanceFormatter:distanceToMe];
    }
    
    // post message date
    NSString *time = [[Utilites shared] fullFormatPassedTimeFromDate:message.datetime];
    
    // putting data to fields
    [self.userPhoto setImageURL:url];
    self.message.text = [tempDict objectForKey:kMessage];
    self.userName.text = [tempDict objectForKey:kUserName];
    self.postMessageDate.text = time;
    
    
    //changing hight
    CGSize textSize = { 225.0, 10000.0 };
    CGSize size = [[self.message text] sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    [self.message setFrame:CGRectMake(75, 43, 225, size.height)];
    [self.colorBuble setFrame:CGRectMake(55, 10, 255, size.height+padding*2)];
}

// HANDLE CELL FOR FB MESSAGE
- (void)handleParametersForCellWithFBMessage:(NSDictionary *)message andIndexPath:(NSIndexPath *)indexPath {

    [self.userPhoto setImage:[UIImage imageNamed:@"human.png"]];
    
    // user message
    NSString *userMessage = [message objectForKey:kMessage];
    //getting Avatar from url
    NSString *friendID = [[message objectForKey:kFrom] objectForKey:kId];
    NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", friendID, [FBStorage shared].accessToken];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // post message date
    NSString *date = [message objectForKey:kCreatedTime];
	NSDate *timeStamp = [[Utilites shared].dateFormatter dateFromString:date];
    NSString *time = [[Utilites shared] fullFormatPassedTimeFromDate:timeStamp];
    
    // putting data to fields
    [self.userPhoto setImageURL:url];
    self.message.text = userMessage;
    self.userName.text = [[message objectForKey:kFrom] objectForKey:kName];
    self.postMessageDate.text = time;
    
    //changing hight
    CGSize textSize = { 225.0, 10000.0 };
    CGSize size = [[self.message text] sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    [self.message setFrame:CGRectMake(75, 43, 225, size.height)];
    [self.colorBuble setFrame:CGRectMake(55, 10, 255, size.height+padding*2)];
}

+ (CGFloat)configureHeightForCellWithMessage:(NSString *)msg {
    CGSize textSize = { 225.0, 10000.0 };
    //changing hight
    CGSize size = [msg sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    size.height += padding*2;
    return size.height+10.0f;
}

//////////////////////////////////////////////////////////////////////////////////
- (void)bubleImageForChatRoomWithUserID:(NSString *)currentID {
    UIImage *bubleImage = nil;
    if ([currentID isEqual:[FBStorage shared].me[kId]] || [[FBStorage shared] isFacebookFriendWithID:currentID]) {
            bubleImage = [[UIImage imageNamed:@"blue_bubble.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    } else {
            bubleImage = [[UIImage imageNamed:@"green_bubble.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    }
    self.colorBuble.image = bubleImage;
}

- (void)bubleImageForDialogWithUserID:(NSString *)currentID {
    UIImage *bubleImage = nil;
    if ([currentID isEqual:[FBStorage shared].me[kId]]) {
        bubleImage = [[UIImage imageNamed:@"blue_bubble.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    } else {
        bubleImage = [[UIImage imageNamed:@"green_bubble.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    }
    self.colorBuble.image = bubleImage;
}

+ (NSString *)imageForMrQuick {
    int index = arc4random()%14;
    NSString *urlString = nil;
    switch (index) {
        case 1:
        {
            urlString = @"https://s3.amazonaws.com/qbprod/94f36229809d4fb28a01959216d3c95800";
            break;
        }
        case 2:
        {
            urlString = @"https://s3.amazonaws.com/qbprod/5bb80e7698ae4d0bad7114444f8028fb00";
            break;
        }
        case 3:
        {
            urlString = @"https://s3.amazonaws.com/qbprod/632d978e0ba04efdb952d85c1db6306b00";
            break;
        }
        case 4:
        {
            urlString = @"https://s3.amazonaws.com/qbprod/4a0d2bb026324e6daba8905ea395a9a700";
            break;
        }
        case 5:
        {
            urlString = @"https://s3.amazonaws.com/qbprod/49b69c5fe731427b96f0ccfa2f90881300";
            break;
        }
        case 6:
        {
            urlString = @"https://s3.amazonaws.com/qbprod/fcc43412e48e495d8c0147471598452100";
            break;
        }
        case 7:
        {
            urlString = @"https://s3.amazonaws.com/qbprod/9c9c14a9de7a47efbc8ae7e7ac5885f500";
            break;
        }
        case 8:
        {
            urlString = @"https://s3.amazonaws.com/qbprod/909257c1601d4164a2a4312cf5b6e78100";
            break;
        }
        case 9:
        {
            urlString = @"https://s3.amazonaws.com/qbprod/46aeede50c0449ba9382fda740e89e0f00";
            break;
        }
        case 10:
        {
            urlString = @"https://s3.amazonaws.com/qbprod/ccb3411e0a4a42bfa99c825dad3c4fdf00";
            break;
        }
        case 11:
        {
            urlString = @"https://s3.amazonaws.com/qbprod/f2e8f470f231483fbb9e690b3a595cf400";
            break;
        }
        case 12:
        {
            urlString = @"https://s3.amazonaws.com/qbprod/a72cc7cb013b457e9dd5d8199862daca00";
            break;
        }
        case 13:
        {
            urlString = @"https://s3.amazonaws.com/qbprod/b9a08586ac5741739f2a04847ba4a8f000";
            break;
        }
        case 14:
        {
            urlString = @"https://s3.amazonaws.com/qbprod/7bd6e98adf8c4c5d98afb1cecb24870e00";
            break;
        }
        default:
            break;
    }
    return urlString;
}

@end
