//
//  Result.h
//  Core
//
//

#import <Foundation/Foundation.h>


@interface Result : NSObject {
	Request *request;
	Answer *answer;
}
@property (nonatomic,retain) Request* request;
@property (nonatomic,retain) Answer* answer;
/** An array of instances of NSError */
@property (nonatomic,readonly) NSArray* errors;
/** YES if operation completed successfully. If equal to NO, see errors for more information */
@property (nonatomic,readonly) BOOL success;
@property (nonatomic,readonly) NSUInteger status;

-(id)initWithRequest:(Request*)req answer:(Answer*)answ;
-(id)initWithAnswer:(Answer*)answ;

@end