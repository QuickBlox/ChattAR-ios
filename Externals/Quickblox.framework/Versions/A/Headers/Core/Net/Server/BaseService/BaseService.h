//
//  BaseService.h
//  BaseService
//
//

#import <Foundation/Foundation.h>

 
@interface BaseService : ServiceDescription{
@protected
	NSString *authKey;
	NSString *authSecret;
	NSString *token;
	NSUInteger appID;
}
@property (nonatomic, readonly) NSString *authKey;
@property (nonatomic, readonly) NSString *authSecret;
@property (nonatomic, readonly) NSUInteger appID;
@property (nonatomic, retain) NSString *token;

+ (BaseService *)sharedServiceForAppId:(NSUInteger)appID key:(NSString *)authKey secret:(NSString *)authSecret;
+ (BaseService *)sharedService;

- (void)resetCredentials;

@end