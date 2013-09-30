//
//  ChatViewController.h
//  ChattAR
//
//  Created by Igor Alefirenko on 28/08/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, QBActionStatusDelegate, QBChatDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSTimer *presenceTimer;

- (IBAction)createPrivateRoom:(id)sender;


@end
