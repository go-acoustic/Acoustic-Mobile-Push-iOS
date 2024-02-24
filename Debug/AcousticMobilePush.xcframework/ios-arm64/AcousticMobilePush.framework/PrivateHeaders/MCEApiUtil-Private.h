//
// Copyright (C) 2024 Acoustic, L.P. All rights reserved.
//
// NOTICE: This file contains material that is confidential and proprietary to
// Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
// industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
// Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
// prohibited.
//

@interface MCEApiUtil (Private)
+ (NSArray * _Nonnull) packageArrayForServer: (NSArray * _Nonnull) array;
+ (NSDictionary * _Nonnull) packageDictionaryForServer: (NSDictionary * _Nonnull) object;
+ (NSDictionary* _Nullable) packageValue: (id _Nonnull) value key: (NSString * _Nonnull) key;
+ (NSArray * _Nonnull) packageAttributes: (NSDictionary * _Nonnull) attributes;
@end
