//
//  VoidWrapper.h
//  SkinCapture
//
//

#import <Foundation/Foundation.h>


@interface VoidWrapper : NSObject {
	void* info;
}
@property (nonatomic,assign) void* info;
+(VoidWrapper*)wrapperForInfo:(void*)info;
@end
