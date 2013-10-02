//
//  ChatViewController.h
//  ChattAR
//
//  Created by Igor Alefirenko on 28/08/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyPaginator.h"

@interface ChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, QBActionStatusDelegate, QBChatDelegate, UIAlertViewDelegate, NMPaginatorDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) MyPaginator *trendingPaginator;
@property (strong, nonatomic) MyPaginator *localPaginator;
@property (strong, nonatomic) NSTimer *presenceTimer;

- (IBAction)createPrivateRoom:(id)sender;


@end
