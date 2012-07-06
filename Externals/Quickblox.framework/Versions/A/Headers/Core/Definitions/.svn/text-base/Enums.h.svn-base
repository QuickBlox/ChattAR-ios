/*
 *  Enums.h
 *  BaseService
 *
 *
 */

enum BaseServiceErrorType 
{
	BaseServiceErrorTypeUnknown = 0,
	BaseServiceErrorTypeValidation,
	BaseServiceErrorTypeParse,
	BaseServiceErrorTypeConnection,
	BaseServiceErrorTypeServer
};

enum RestMethodKind
{
	RestMethodKindDELETE = 1,
	RestMethodKindGET,
	RestMethodKindPOST,
	RestMethodKindPUT,
    RestMethodKindHEAD
};

//ASIHTTPRequest
enum RestResponseType
{
	RestResponseTypeXML,
	RestResponseTypePlain,
	RestResponseTypeBinary,
	RestResponseTypeHTML,
	RestResponseTypeUnknown
}; 


enum RestAnswerKind
{
	RestAnswerKindUnknown,
	RestAnswerKindAccepted = 202,
	RestAnswerKindCreated = 201,
	RestAnswerKindNotFound = 404,
	RestAnswerKindOK = 200,
	RestAnswerKindServerError = 500,
	RestAnswerKindUnAuthorized = 401,
	RestAnswerKindValidationFailed = 422
};

enum ServerZone
{
	ServerZoneTest,
	ServerZoneDevelopment,
	ServerZoneProduction
};

enum QBLogLevel
{
	QBLogLevelNothing,
	QBLogLevelVerboseOnly,
	QBLogLevelErrors,
	QBLogLevelWarnings,
	QBLogLevelInfo,
	QBLogLevelDebug
};

enum RestRequestBuildStyle
{
	RestRequestBuildStyleParams,
	RestRequestBuildStyleMultipartFormData,
	RestRequestBuildStyleBinary
};

enum FileParameterType
{
	FileParameterTypePath,
	FileParameterTypeData
}; 