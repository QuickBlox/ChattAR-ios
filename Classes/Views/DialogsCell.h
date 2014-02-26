//
//  DialogsCell.h
//  ChattAR
//
//  Created by Igor Alefirenko on 29/10/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface DialogsCell : UITableViewCell

@property (nonatomic, strong) IBOutlet AsyncImageView *asyncView;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *userMessage;
@property (strong, nonatomic) IBOutlet UIImageView *replyArrow;
@property (strong, nonatomic) IBOutlet UILabel *dateTime;

+ (void)configureDialogsCell:(DialogsCell *)cell forIndexPath:(NSIndexPath *)indexPath forUser:(NSDictionary *)user;

@end
