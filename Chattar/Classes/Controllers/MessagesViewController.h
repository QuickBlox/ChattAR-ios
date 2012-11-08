//
//  MessagesViewController.h
//  ChattAR for facebook
//
//  Created by QuickBlox developers on 03.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBServiceResultDelegate.h"
#import "AsyncImageView.h"
#import "ViewTouch.h"
#import "MBProgressHUD.h"

#import "FBChatViewController.h"

@interface MessagesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, FBServiceResultDelegate, UISearchBarDelegate, MBProgressHUDDelegate>
{	
	// data
    NSMutableArray		*searchArray;
    
    ViewTouch				*backView;
    MBProgressHUD *HUD;
    
    BOOL isInitialized;
}


@property (retain, nonatomic) IBOutlet UISearchBar				*searchField;
@property (retain, nonatomic) IBOutlet UITableView				*messageTableView;

@end
