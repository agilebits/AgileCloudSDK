//
//  Defines.h
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/5/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#ifndef Defines_h
#define Defines_h

#define kUndefinedMethodException [NSException exceptionWithName:@"UndefinedMethodException" reason:@"Method not yet defined" userInfo:nil]
#define kAbstractMethodException [NSException exceptionWithName:@"AbstractMethodException" reason:@"Must implement method in subclass" userInfo:nil]
#define kInvalidMethodException [NSException exceptionWithName:@"InvalidMethodException" reason:@"This method cannot be called outside the class" userInfo:nil]

#ifdef DEBUG
#define DebugLog(__FORMAT__, ...) NSLog(__FORMAT__, ##__VA_ARGS__)
#else
#define DebugLog(__FORMAT__, ...)
#endif

#endif /* Defines_h */
