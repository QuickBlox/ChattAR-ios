//
//  QBMGetTokenPerformer.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBMGetTokenPerformer : QBApplicationRedelegate<Perform,Cancelable> {
	NSObject<ActionStatusDelegate> * performDelegate;
	VoidWrapper *context;
	NSRecursiveLock *canceledLock;
    
	BOOL completed;
	BOOL isCanceled;
}
@property (nonatomic, retain) NSObject<ActionStatusDelegate> *performDelegate;
@property (nonatomic, retain) VoidWrapper *context;
@property (nonatomic, retain) NSRecursiveLock *canceledLock;

@property (nonatomic) BOOL completed;
@property (nonatomic) BOOL isCanceled;

- (void)actionInBg;
- (void)performAction;

- (void)tokenRequestTimedOut;

@end
