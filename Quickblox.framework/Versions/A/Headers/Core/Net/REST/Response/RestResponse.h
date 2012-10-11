//
//  RestResponse.h
//  Core
//
//

@interface RestResponse : NSObject{
	NSDictionary *headers;
	NSData *body;
	NSError *error;
	ASIHTTPRequest* asirequest;
}

@property (nonatomic, retain) NSDictionary *headers;
@property (nonatomic, retain) NSData *body;
@property (readonly) NSUInteger status;
@property (readonly) enum RestResponseType responseType;
@property (readonly) NSString* contentType;
@property (nonatomic, retain) NSError *error;
@property (readonly) ASIHTTPRequest* asirequest;
@property (nonatomic,readonly) NSStringEncoding encoding;

-(id)initWithAsiRequest:(ASIHTTPRequest*)_asirequest;
+(enum RestResponseType)getResponseType:(NSString *)mimeType;

@end
