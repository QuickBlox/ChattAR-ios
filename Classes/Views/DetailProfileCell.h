//
//  DetailProfileCell.h
//  ChattAR
//
//  Created by Igor Alefirenko on 06/12/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailProfileCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *keyField;
@property (strong, nonatomic) IBOutlet UILabel *valueField;

- (void)handleCellWithContent:(NSDictionary *)content;

@end
