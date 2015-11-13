//
//  CLLocation+AgileDictionary.m
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/14/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import "CLLocation+AgileDictionary.h"

@implementation CLLocation (AgileDictionary)

- (NSDictionary *)asAgileDictionary
{
    return @{ @"latitude": @(self.coordinate.latitude),
              @"longitude": @(self.coordinate.longitude) };
}

@end
