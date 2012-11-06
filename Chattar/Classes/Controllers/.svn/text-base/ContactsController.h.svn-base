//
//  ContactsController.h
//  FB_Radar
//
//  Created by md314 on 3/10/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBServiceResultDelegate.h"
#import "ViewTouch.h"

@interface ContactsController : UIViewController <UITableViewDataSource, UITableViewDelegate, FBServiceResultDelegate, UISearchBarDelegate>
{
    
    // friends by sections
	NSMutableArray		*favoriteFriends;
	NSMutableArray		*onlineFriends;
	NSMutableArray		*offlineFriends;
	
	// back view fro hide keyboard
    ViewTouch			*backView;
	
	// search data
    NSMutableArray		*searchArray;
    
    BOOL isInitialized;
}

@property (retain, nonatomic) IBOutlet UITableView				*friendListTableView;
@property (retain, nonatomic) IBOutlet UISearchBar				*searchField;

@end
