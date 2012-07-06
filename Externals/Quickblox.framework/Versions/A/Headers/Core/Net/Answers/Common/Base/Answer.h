//
//  Answer.h
//  BaseService
//
//

@interface Answer : NSObject {
	NSMutableArray *errors;
	BOOL isSucceeded;
}
@property (nonatomic, retain) NSMutableArray* errors;
@property (nonatomic) BOOL isSucceeded;

-(Result*)allocResult;
-(void)addTextError:(NSString*)text;

@end