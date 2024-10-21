/*
 * Copyright (C) 2024 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */
 
#if __has_feature(modules)
@import UIKit;
@import AcousticMobilePush;
#else
#import <UIKit/UIKit.h>
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

@interface MCEInboxPostTemplate : NSObject <MCETemplate,UIContentContainer>
@property(class, nonatomic, readonly) MCEInboxPostTemplate * sharedInstance NS_SWIFT_NAME(shared);
@property NSMutableDictionary * contentSizeCache;
@property NSMutableDictionary * postHeightCache;
+(void)registerTemplate;
@end
