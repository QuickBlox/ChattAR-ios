//
//  Query.h
//  Core
//
//
@class BaseService;
@interface Query : NSObject<Perform,RestRequestDelegate,Cancelable> 
{
	NSObject<ActionStatusDelegate>* delegate;
	NSObject<Cancelable>* canceler;
	BOOL isCanceled;
	NSRecursiveLock* canceledLock;
	VoidWrapper* context;
	BOOL verboseMode;
	enum RestRequestBuildStyle requestBuildStyle;
}
@property (nonatomic,retain) NSObject<ActionStatusDelegate>* delegate;
@property (nonatomic,retain) NSObject<Cancelable>* canceler;
@property (nonatomic,retain) NSRecursiveLock* canceledLock;
@property (nonatomic,retain) VoidWrapper* context;
@property (nonatomic) BOOL verboseMode;
@property (nonatomic) enum RestRequestBuildStyle requestBuildStyle;

- (RestAnswer*)allocAnswer;
- (RestRequest*)request;
- (RestRequest*)requestAsync;
- (NSString*)url;
- (void)setupRequest:(RestRequest*)request;
- (void)setUrl:(RestRequest*)request;
- (void)setAuthentication:(RestRequest*)request;
- (void)setBody:(RestRequest*)request;
- (void)setParams:(RestRequest*)request;
- (void)setHeaders:(RestRequest*)request;
- (void)setMethod:(RestRequest*)request;
- (void)setFiles:(RestRequest*)request;
- (void)setShouldRedirect:(RestRequest*)request;
- (Class)serviceClass;
- (BaseService*)service;
@end
