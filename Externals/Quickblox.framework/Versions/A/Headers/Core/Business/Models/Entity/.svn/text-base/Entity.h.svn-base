//
//  Entity.h
//  Core
//
//

#import <Foundation/Foundation.h>


@interface Entity : NSObject {
	NSDate *createdAt;
	NSDate *updatedAt;
@private
	BOOL autosave;
	NSUInteger ID;
}
/** Entity class declaration */
/** Overview: Base class for the most business objects */
/** Identifier */
@property (nonatomic) NSUInteger ID;
@property (nonatomic) BOOL autosave;
@property (nonatomic,retain) NSDate* createdAt;
@property (nonatomic,retain) NSDate* updatedAt;
-(BOOL)create;
-(BOOL)save;
-(BOOL)destroy;
-(BOOL)refresh;
-(void)changed;
@end
