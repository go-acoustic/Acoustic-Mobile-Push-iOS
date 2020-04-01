/*
* Copyright © 2019 Acoustic, L.P. All rights reserved.
*
* NOTICE: This file contains material that is confidential and proprietary to
* Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
* industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
* Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
* prohibited.
*/

#import "UIColor+data.h"

@implementation UIColor (data)

-(NSData*) data {
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

+(UIColor*)from: (NSData*) data {
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
