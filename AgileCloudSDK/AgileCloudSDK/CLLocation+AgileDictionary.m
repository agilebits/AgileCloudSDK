//
//  CLLocation+AgileDictionary.m
//  AgileCloudSDK
//

//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "CLLocation+AgileDictionary.h"

@implementation CLLocation (AgileDictionary)

- (NSDictionary *)asAgileDictionary
{
    return @{ @"latitude": @(self.coordinate.latitude),
              @"longitude": @(self.coordinate.longitude) };
}

@end
