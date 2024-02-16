//
// Copyright (C) 2024 Acoustic, L.P. All rights reserved.
//
// NOTICE: This file contains material that is confidential and proprietary to
// Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
// industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
// Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
// prohibited.
//

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MCE_LOG_LEVELS) {
    LOG_LEVEL_OFF,
    LOG_LEVEL_ERROR,
    LOG_LEVEL_WARN,
    LOG_LEVEL_INFO,
    LOG_LEVEL_VERBOSE,
    LOG_LEVEL_TRACE
};

@interface MCELog : NSObject
@property(class, nonatomic, readonly) MCELog * _Nonnull sharedInstance NS_SWIFT_NAME(shared);
@property (readonly) NSDictionary * logLevelNames;
@property NSString * logLevelName;

@property unsigned long long maximumSize; // default to 10MB
@property int maximumNumberOfLogFiles;    // default to 7
@property BOOL logToFile;                 // default to false
@end

void MCELogVerbose(NSString * format, ...);
void MCELogError(NSString * format, ...);
void MCELogInfo(NSString * format, ...);
void MCELogWarn(NSString * format, ...);
void MCELogTrace(NSString * format, ...);
void MCELogWrite(MCE_LOG_LEVELS level, NSString * format, va_list args);

NS_ASSUME_NONNULL_END
