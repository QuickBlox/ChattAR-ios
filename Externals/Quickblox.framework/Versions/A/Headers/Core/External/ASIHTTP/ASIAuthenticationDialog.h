//
//  ASIAuthenticationDialog.h
//  Part of ASIHTTPRequest -> http://allseeing-i.com/ASIHTTPRequest
//
//

#import <Foundation/Foundation.h>
@class ASIHTTPRequest;

typedef enum _ASIAuthenticationType {
	ASIStandardAuthenticationType = 0,
    ASIProxyAuthenticationType = 1
} ASIAuthenticationType;
	
@interface ASIAuthenticationDialog : NSObject <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource> {
	ASIHTTPRequest *request;
	UIActionSheet *loginDialog;
	ASIAuthenticationType type;
}
+ (void)presentAuthenticationDialogForRequest:(ASIHTTPRequest *)request;
+ (void)presentProxyAuthenticationDialogForRequest:(ASIHTTPRequest *)request;

@property (retain) ASIHTTPRequest *request;
@property (retain) UIActionSheet *loginDialog;
@property (assign) ASIAuthenticationType type;
@end
