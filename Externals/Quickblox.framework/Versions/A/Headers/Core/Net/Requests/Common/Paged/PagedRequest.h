//
//  PagedRequest.h
//  Core
//
//

#import <Foundation/Foundation.h>

@class PagedResult;
@interface PagedRequest : Request {
@protected
	NSUInteger page;
	NSUInteger perPage;
}
@property (nonatomic) NSUInteger page;
@property (nonatomic) NSUInteger perPage;

/*
-(PagedResult *)performWithPage:(NSUInteger)newPageNumber perPage:(NSUInteger)newPerPage;
-(PagedResult *)performWithPage:(NSUInteger)newPageNumber;
*/

@end
