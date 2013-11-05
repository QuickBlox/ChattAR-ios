//
//  DialogsViewController.h
//  ChattAR
//
//  Created by Igor Alefirenko on 29/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBServiceResultDelegate.h"

@interface DialogsViewController : UITableViewController <UISearchBarDelegate, FBServiceResultDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSMutableArray *searchContent;

@end
