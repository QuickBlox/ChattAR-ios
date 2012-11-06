//
//  ChattARApplication.m
//  Chattar
//
//  Created by Tatyana Akulova on 9/16/12.
//
//

#import "ChattARApplication.h"
#import "WebViewController.h"
#import "AppDelegate.h"

@implementation ChattARApplication

-(BOOL)openURL:(NSURL *)url{
    UITabBarController *tabBarControlelr = ((AppDelegate *)self.delegate).tabBarController;
    if(tabBarControlelr.selectedIndex != 1){
        return [super openURL:url];
    }
    
    // handle chat messages' links
    WebViewController *webViewControleler = [[WebViewController alloc] init];
    webViewControleler.urlAdress = [url absoluteString];
    webViewControleler.webView.scalesPageToFit = YES;
    UINavigationController *chatViewController = [tabBarControlelr.viewControllers objectAtIndex:1];
	[chatViewController pushViewController:webViewControleler animated:YES];
    [webViewControleler autorelease];
    
    return NO;
}

@end
