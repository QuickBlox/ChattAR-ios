//
//  QBMPushMessageBase.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBMPushMessageBase : NSObject <NSCoding, NSCopying>{
	NSMutableDictionary *payloadDict;
}
@property (nonatomic,retain) NSMutableDictionary *payloadDict;

+ (SBJsonWriter *)defaultJsonWriter;
+ (SBJsonParser *)defaultJsonParser;
+ (QBMPushMessageBase *)fromJson:(NSString *)json;
- (id)initWithJson:(NSString *)json;
- (id)initWithPayload:(NSDictionary *)payload;
- (NSString *)json;
- (int)charsLeft;

@end
