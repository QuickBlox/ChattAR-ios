//
//  DialogsCell.h
//  ChattAR
//
//  Created by Igor Alefirenko on 29/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface DialogsCell : UITableViewCell

@property (nonatomic, strong) IBOutlet AsyncImageView *asyncView;
@property (strong, nonatomic) IBOutlet UILabel *name;

+ (void)configureDialogsCell:(DialogsCell *)cell forIndexPath:(NSIndexPath *)indexPath forFriend:(NSDictionary *)aFriend;

@end
