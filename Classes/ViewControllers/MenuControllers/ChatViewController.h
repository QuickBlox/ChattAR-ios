//
//  ChatViewController.h
//  ChattAR
//
//  Created by Igor Alefirenko on 28/08/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatRoomsPaginator.h"

@interface ChatViewController : UIViewController 

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) ChatRoomsPaginator *trendingPaginator;
@property (strong, nonatomic) UIActivityIndicatorView *searchIndicatorView;

- (IBAction)createChatRoom:(id)sender;


@end
