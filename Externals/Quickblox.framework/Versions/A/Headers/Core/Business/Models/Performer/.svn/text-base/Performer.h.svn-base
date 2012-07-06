//
//  Performer.h
//  Core
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Performer : NSObject<Perform,Cancelable> {

	NSObject<ActionStatusDelegate>* delegate;
	NSObject<Cancelable>* canceler;
	BOOL isCanceled;
	NSRecursiveLock* canceledLock;
	VoidWrapper* context;
	BOOL verboseMode;
}
@property (nonatomic,retain) NSObject<ActionStatusDelegate>* delegate;
@property (nonatomic,retain) NSObject<Cancelable>* canceler;
@property (nonatomic,retain) NSRecursiveLock* canceledLock;
@property (nonatomic,retain) VoidWrapper* context;
@property (nonatomic) BOOL verboseMode;

@end

@interface Performer (ActionPerform)

- (void)performInBgAsyncWithDelegate:(NSObject<ActionStatusDelegate>*)_delegate;
- (void)performAction;
- (void)actionInBg;
- (Result*)actionSync;
- (void)prepare;
@end

