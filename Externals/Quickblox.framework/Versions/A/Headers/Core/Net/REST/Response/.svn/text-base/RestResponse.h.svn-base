//
//  RestResponse.h
//  Core
//
//

@interface RestResponse : NSObject
{
	RestRequest *request;
	NSDictionary *headers;
	NSData *body;
	NSHTTPURLResponse *response;
	NSError *error;
	ASIHTTPRequest* asirequest;
}

@property (readonly) RestRequest *request;
@property (nonatomic, retain) NSDictionary *headers;
@property (nonatomic, retain) NSData *body;
@property (readonly) NSHTTPURLResponse *response;
@property (readonly) NSUInteger status;
@property (readonly) enum RestResponseType responseType;
@property (readonly) NSString* contentType;
@property (nonatomic, retain) NSError *error;
@property (readonly) ASIHTTPRequest* asirequest;
@property (nonatomic,readonly) NSStringEncoding encoding;
-(id)initWithRequest:(RestRequest *)_request response:(NSHTTPURLResponse *)_response body:(NSData *)_body error:(NSError *)_error;
-(id)initWithAsiRequest:(ASIHTTPRequest*)_asirequest;
+(enum RestResponseType)getResponseType:(NSString *)mimeType;

@end
