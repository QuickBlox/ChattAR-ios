/*
 *  Consts.h
 *  BaseService
 *
 *
 */

#define N(V) (V==nil)?@"":V
#define S(S,F) [NSString stringWithFormat:S,F]


extern NSString* const kBaseServiceErrorDomain;
extern NSString* const kBaseServiceErrorKeyDescription;
extern NSString* const kBaseServiceErrorKeyInner;
extern NSString* const kBaseServiceException;

//Errors
extern NSString* const kBaseServiceErrorTimeout;
extern NSString* const kBaseServiceErrorNotFound;
extern NSString* const kBaseServiceErrorValidation;
extern NSString* const kBaseServiceErrorUnauthorized;
extern NSString* const kBaseServiceErrorUnexpectedStatus;
extern NSString* const kBaseServiceErrorUnexpectedContentType;
extern NSString* const kBaseServiceErrorUnknownContentType;
extern NSString* const kBaseServiceErrorInternalError;

//Exceptions
extern NSString* const kBaseServiceExceptionMissedAuthorization;

//Service Names
extern NSString* const QuickbloxServiceChat;

//Service description keys
extern NSString* const MobservServiceDescriptionDomainKey;
extern NSString* const MobservServiceDescriptionDevDomainKey;
extern NSString* const MobservServiceDescriptionProdDomainKey;
extern NSString* const MobservServiceDescriptionTestDomainKey;
extern NSString* const MobservServiceDescriptionZoneKey;


#define kBaseServiceDateNotSet [NSDate dateWithTimeIntervalSince1970:0] 
#define kBaseServiceObjectNotSet nil
#define kBaseServiceIDNotSet 0
#define kBaseServiceStringNotSet [NSString string]
#define kBaseServiceBoolNotSet FALSE
#define kBaseServiceValueNotSet 0

#define kBaseServicePageNotSet 0
#define kBaseServicePerPageNotSet 0

// log
#define QBDL(...) if([QBSettings logLevel]>=QBLogLevelDebug) [AsyncLogger LogF:[NSString stringWithFormat:__VA_ARGS__]] 

#define E(A,B,C) @throw [NSException exceptionWithName:A reason:B userInfo:C];
#define E2(A,B) @throw [NSException exceptionWithName:A reason:B userInfo:nil];
#define EB(B,C) E(kBaseServiceException, B,C)
#define EB2(B) E2(kBaseServiceException, B)