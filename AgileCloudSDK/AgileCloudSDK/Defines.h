//
//  Defines.h
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#ifndef Defines_h
#define Defines_h

#define kUndefinedMethodException [NSException exceptionWithName:@"UndefinedMethodException" reason:@"Method not yet defined" userInfo:nil]
#define kAbstractMethodException [NSException exceptionWithName:@"AbstractMethodException" reason:@"Must implement method in subclass" userInfo:nil]
#define kInvalidMethodException [NSException exceptionWithName:@"InvalidMethodException" reason:@"This method cannot be called outside the class" userInfo:nil]

//#define DebugLog(__FORMAT__, ...) NSLog(__FORMAT__, ##__VA_ARGS__)
#define DebugLog(level, __FORMAT__, ...) if ([[CKMediator sharedMediator].delegate respondsToSelector:@selector(mediator:logLevel:object:at:format:)]) [[CKMediator sharedMediator].delegate mediator:[CKMediator sharedMediator] logLevel:level object:self at:_cmd format:__FORMAT__, ##__VA_ARGS__]

#endif /* Defines_h */
