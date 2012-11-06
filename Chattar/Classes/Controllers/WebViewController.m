//
//  WebViewController.m
//  FB_Radar
//
//  Created by Sonny Black on 07.06.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

@synthesize webView, loadUrlProgress;
@synthesize urlAdress;
@synthesize request;

- (void)viewDidLoad
{	
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Web", @"Web");
    
    if(urlAdress != nil){
        NSURL *url = [NSURL URLWithString:urlAdress];
        NSURLRequest *_request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:_request];
    }else if(request != nil){
        [webView loadRequest:request];
    }
}

- (void)viewDidUnload
{	
	self.webView = nil;
    self.loadUrlProgress = nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)dealloc
{
	[urlAdress release];
	
	[super dealloc];
    
    self = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark WebViewDelegate

-(void)webViewDidStartLoad:(UIWebView *)webView{
	[loadUrlProgress startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
	[loadUrlProgress stopAnimating];
}

@end
