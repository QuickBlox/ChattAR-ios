//
//  QBAuthService.h
//  AuthService
//
//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

/** QBAuthService class declaration. */
/** Overview */
/** This class is the main entry point to work with Quickblox Auth module. */

@interface QBAuthService : BaseService {

}

#pragma mark -
#pragma mark App authorization

/**
 Session Creation
 
 Type of Result - QBAAuthSessionCreationResult.
 
 @param appID Application identifier (from admin.quickblox.com)
 @param authKey API Application identification key (from admin.quickblox.com). This key is created at the time of adding a new application to your Account through the web interface. You can not set it yourself. You should use this key in your API Application to get access to QuickBlox through the API interface.
 @param authSecret Secret sequence which is used to prove Authentication Key (from admin.quickblox.com). It's similar to a password. You have to keep it private and restrict access to it. Use it in your API Application to create your signature for authentication request.
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained.  Upon finish of the request, result will be an instance of QBAAuthSessionCreationResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+(NSObject<Cancelable> *)createSessionWithAppId:(NSUInteger)appID key:(NSString *)authKey secret:(NSString *)authSecret delegate:(NSObject<ActionStatusDelegate> *)delegate;
+(NSObject<Cancelable> *)createSessionWithAppId:(NSUInteger)appID key:(NSString *)authKey secret:(NSString *)authSecret delegate:(NSObject<ActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark App authorization with extended Request

/**
 Session Creation with extended Request
 
 Type of Result - QBAAuthSessionCreationResult.
 
 @param appID Application identifier (from admin.quickblox.com)
 @param authKey API Application identification key (from admin.quickblox.com). This key is created at the time of adding a new application to your Account through the web interface. You can not set it yourself. You should use this key in your API Application to get access to QuickBlox through the API interface.
 @param authSecret Secret sequence which is used to prove Authentication Key (from admin.quickblox.com). It's similar to a password. You have to keep it private and restrict access to it. Use it in your API Application to create your signature for authentication request.
 @param extendedRequest Extended set of request parameters
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained.  Upon finish of the request, result will be an instance of QBAAuthSessionCreationResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+(NSObject<Cancelable> *)createSessionWithAppId:(NSUInteger)appID key:(NSString *)authKey secret:(NSString *)authSecret extendedRequest:(QBASessionCreationRequest *)extendedRequest delegate:(NSObject<ActionStatusDelegate> *)delegate;
+(NSObject<Cancelable> *)createSessionWithAppId:(NSUInteger)appID key:(NSString *)authKey secret:(NSString *)authSecret extendedRequest:(QBASessionCreationRequest *)extendedRequest delegate:(NSObject<ActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Delete session

/**
 Session Destroy
 
 Type of Result - QBAAuthResult.
 
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained.  Upon finish of the request, result will be an instance of QBAAuthResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+(NSObject<Cancelable> *)destroySessionWithDelegate:(NSObject<ActionStatusDelegate> *)delegate;
+(NSObject<Cancelable> *)destroySessionWithDelegate:(NSObject<ActionStatusDelegate> *)delegate context:(void *)context;

@end
