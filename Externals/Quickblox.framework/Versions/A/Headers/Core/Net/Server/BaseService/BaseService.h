//
//  BaseService.h
//  BaseService
//
//

#import <Foundation/Foundation.h>

 
@interface BaseService : NSObject{
}

@property (nonatomic, retain) NSString *token;

+ (void) createSharedService;
+ (BaseService *) sharedService;

- (void)resetToken;

#pragma mark -
#pragma mark Server endpoint url

+ (NSString *)serverEndpointURL;

@end