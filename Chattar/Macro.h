//
//  Macro.h
//  ChattAR for facebook
//
//  Created by QuickBlox developers on 8/2/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#ifndef Chattar_Macro_h
#define Chattar_Macro_h

#define SERIALIZE_OBJECT(var_name, coder)		[coder encodeObject:var_name forKey:@#var_name]
#define SERIALIZE_INT(var_name, coder)			[coder encodeInt:var_name forKey:@#var_name]
#define SERIALIZE_INT64(var_name, coder)		[coder encodeInt64:var_name forKey:@#var_name]
#define SERIALIZE_FLOAT(var_name, coder)		[coder encodeFloat:var_name forKey:@#var_name]
#define SERIALIZE_DOUBLE(var_name, coder)		[coder encodeDouble:var_name forKey:@#var_name]
#define SERIALIZE_BOOL(var_name, coder)			[coder encodeBool:var_name forKey:@#var_name]

#define DESERIALIZE_OBJECT(var_name, decoder)	var_name = [[decoder decodeObjectForKey:@#var_name] retain]
#define DESERIALIZE_INT(var_name, decoder)		var_name = [decoder decodeIntForKey:@#var_name]
#define DESERIALIZE_INT64(var_name, decoder)	var_name = [decoder decodeInt64ForKey:@#var_name]
#define DESERIALIZE_FLOAT(var_name, decoder)	var_name = [decoder decodeFloatForKey:@#var_name]
#define DESERIALIZE_DOUBLE(var_name, decoder)	var_name = [decoder decodeDoubleForKey:@#var_name]
#define DESERIALIZE_BOOL(var_name, decoder)		var_name = [decoder decodeBoolForKey:@#var_name]

#define IS_HEIGHT_GTE_568 [[UIScreen mainScreen ] bounds].size.height >= 568.0f

#define IS_IOS_6 [[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0f
#endif
