//
//  QBMessagesService.h
//  MessagesService
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

/** QBMessagesService class declaration. */
/** Overview: this is a hub class for all Messages-related actions. */

@interface QBMessagesService : BaseService {
    
}



#pragma mark -
#pragma mark Push Token:Create

/** Create device token.
 
 */
+ (NSObject<Cancelable> *)registerPushToken:(QBMPushToken *)deviceToken withDelegate:(NSObject<ActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)registerPushToken:(QBMPushToken *)deviceToken withDelegate:(NSObject<ActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Subscription:Create

/** Create Subscription.
 
 */
+ (NSObject<Cancelable> *)createSubscription:(QBMSubscription *)subscriber withDelegate:(NSObject<ActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)createSubscription:(QBMSubscription *)subscriber withDelegate:(NSObject<ActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Event:Create 

/** Create an event
 
 @param event event to create
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained.  Upon finish of the request, result will be an instance of QBMEventResult class.
 */
+ (NSObject<Cancelable> *)createEvent:(QBMEvent *)event delegate:(NSObject<ActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)createEvent:(QBMEvent *)event delegate:(NSObject<ActionStatusDelegate> *)delegate context:(void *)context;



#pragma mark -
#pragma mark Task:Register Subscription

/** Create subscription for existing user. 
 
 This method registers push token on the server if they are not registered yet, then creates a Subscription and associates it with User. 
 
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained.  Upon finish of the request, result will be an instance of QBMRegisterSubscriptionTaskResult class.
 */
+ (NSObject<Cancelable> *)TRegisterSubscriptionWithDelegate:(NSObject<ActionStatusDelegate> *)delegate;


#pragma mark -
#pragma mark Task: Send Push

/** Send push message to external user
 
 @param pushMessage composed push message to send
 @param usersIDs users identifiers. Contain a string of users ids divided by comas.
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained.  Upon finish of the request, result will be an instance of QBMSendPushTaskResult class.
 */
+ (NSObject<Cancelable> *)TSendPush:(QBMPushMessage *)pushMessage 
                            toUsers:(NSString *)usersIDs 
             environmentDevelopment:(BOOL)isEnvironmentDevelopment
						   delegate:(NSObject<ActionStatusDelegate> *)delegate;




@end
