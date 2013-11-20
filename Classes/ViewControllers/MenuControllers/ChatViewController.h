//
//  ChatViewController.h
//  ChattAR
//
//  Created by Igor Alefirenko on 28/08/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatRoomsPaginator.h"

@interface ChatViewController : UIViewController 

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) ChatRoomsPaginator *trendingPaginator;

- (IBAction)createChatRoom:(id)sender;


@end
