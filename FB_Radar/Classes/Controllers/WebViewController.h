//
//  WebViewController.h
//  FB_Radar
//
//  Created by Sonny Black on 07.06.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>{
}

@property (nonatomic, assign) IBOutlet UIWebView *webView;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *loadUrlProgress;
@property (nonatomic, retain) NSString *urlAdress;
@property (nonatomic, retain) NSURLRequest *request;

@end
