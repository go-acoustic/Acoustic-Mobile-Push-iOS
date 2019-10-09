/*
* Copyright © 2019 Acoustic, L.P. All rights reserved.
*
* NOTICE: This file contains material that is confidential and proprietary to
* Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
* industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
* Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
* prohibited.
*/

#import "UIColor+Sample.h"
#import <AcousticMobilePush/AcousticMobilePush.h>

@implementation UIColor (Sample)

+(instancetype)disabledColor {
    return [UIColor lightThemeColor: UIColor.grayColor darkThemeColor: UIColor.lightGrayColor];
}

+(instancetype)tintColor {
    return [UIColor lightThemeColor: [UIColor colorWithHexString:@"047970"] darkThemeColor: [UIColor colorWithHexString:@"1BF7A8"]];
}

+(instancetype)foregroundColor {
    return [UIColor lightThemeColor: UIColor.blackColor darkThemeColor: UIColor.whiteColor];
}

+(instancetype)failureColor {
    return [UIColor lightThemeColor: [UIColor colorWithHexString:@"810000"] darkThemeColor: [UIColor colorWithHexString:@"C30000"]];
}

+(instancetype)warningColor {
    return [UIColor lightThemeColor: [UIColor colorWithHexString:@"929000"] darkThemeColor: [UIColor colorWithHexString:@"C1BA28"]];
}

+(instancetype)successColor {
    return [UIColor lightThemeColor: [UIColor colorWithHexString:@"008000"] darkThemeColor: [UIColor colorWithHexString:@"00b200"]];
}

@end
