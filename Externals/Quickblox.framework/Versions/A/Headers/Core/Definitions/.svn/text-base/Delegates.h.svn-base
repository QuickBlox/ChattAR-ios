/*
 *  Delegates.h
 *  
 *
 *
 */
@protocol StatusReporter

-(void)progress:(int)progress;
-(void)result:(id)result;
-(void)error:(NSError*)error;

@end
@protocol Progressable

-(void)progress:(int)progress;

@end
/** Protocol of cancelable objects, mostly used with asynchronous operations */
@protocol Cancelable
/** Cancel current execution */
-(void)cancel;
@end

@class Result;
/** Protocol for asynchronous requests delegates */
@protocol ActionStatusDelegate
/** Called when operation has completed */
-(void)completedWithResult:(Result*)result;
@optional
/** Called when operation has completed and context was set upon starting of the operation */
-(void)completedWithResult:(Result*)result context:(void*)contextInfo;
/** Called when operation progress has changed */
-(void)setProgress:(float)progress;
-(void)setUploadProgress:(float)progress;
@end

@protocol ProgressDelegate
-(void)setProgress:(float)progress;
@end

@protocol LoadProgressDelegate
-(void)setUploadProgress:(float)progress;
-(void)setDownloadProgress:(float)progress;
@optional
-(void)setProgress:(float)progress;
@end

@class RestResponse;
@protocol RestRequestDelegate<LoadProgressDelegate>
-(void)completedWithResponse:(RestResponse*)response;
@end

@class RestAnswer;
@protocol QueryDelegate
-(void)completedWithAnswer:(RestAnswer*)answer;
@optional
-(void)setProgress:(float)progress;
@end

@protocol Perform
-(Result*)perform;
-(NSObject<Cancelable>*)performAsyncWithDelegate:(NSObject<ActionStatusDelegate>*)delegate;
-(NSObject<Cancelable>*)performAsyncWithDelegate:(NSObject<ActionStatusDelegate>*)delegate context:(void*)context;
@end