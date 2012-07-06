//
//  RestRequest.h
//  Core
//
//


@interface RestRequest : NSObject<Cancelable>
{
	enum RestMethodKind method;
	NSURL *URL;
	NSDictionary *headers;
	NSDictionary *parameters;
	NSArray *files;
	NSData *body;
	NSObject<RestRequestDelegate>* delegate;
	BOOL useAuthentication;
	NSString* login;
	NSString* password;
	ProgressDispatcher* uploadDispatcher;
	ProgressDispatcher* downloadDispatcher;
	NSRecursiveLock *canceledLock;
	NSObject<Cancelable>* canceler;
	BOOL isCanceled;
	BOOL verboseMode;
	enum RestRequestBuildStyle buildStyle;
	BOOL shouldRedirect;
}

@property (nonatomic) enum RestMethodKind method;
@property(nonatomic, retain) NSObject<RestRequestDelegate>* delegate;
@property(nonatomic, retain) NSURL *URL;
@property(nonatomic, retain) NSDictionary *headers;
@property(nonatomic, retain) NSDictionary *parameters;
@property(nonatomic, retain) NSArray *files;
@property(nonatomic, retain) NSData *body;
@property(nonatomic, readonly) NSData* rawBody;
@property(nonatomic, readonly) NSString* httpMethod;
@property(nonatomic) BOOL useAuthentication;
@property(nonatomic, retain) NSString* login;
@property(nonatomic, retain) NSString* password;
@property(readonly) NSURLRequest *request;

@property(readonly) ASIHTTPRequest* asirequestAsync;
@property(readonly) ASIHTTPRequest* asirequest;


@property(readonly) NSURL *finalURL;
@property(nonatomic, retain) ProgressDispatcher* uploadDispatcher;
@property(nonatomic, retain) ProgressDispatcher* downloadDispatcher;
@property(nonatomic, retain) NSRecursiveLock *canceledLock;
@property(nonatomic, retain) NSObject<Cancelable>* canceler;
@property(nonatomic) BOOL verboseMode, shouldRedirect;
@property(nonatomic) enum RestRequestBuildStyle buildStyle;


- (void)asyncRequestWithdelegate:(NSObject<RestRequestDelegate>*)delegate;
- (RestResponse *)syncRequest;

- (void)ldAsync:(NSArray*)args;
- (void)ld:(NSArray*)args;
+ (NSString *)httpMethod:(enum RestMethodKind)method;
- (void)setMultipartParts:(ASIFormDataRequest*)asireq;
@end
