//
// Copyright (C) 2024 Acoustic, L.P. All rights reserved.
//
// NOTICE: This file contains material that is confidential and proprietary to
// Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
// industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
// Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
// prohibited.
//

@interface MCEArea(Private)

@property (readonly) double latitude;
@property (readonly) double longitude;
@property (readonly) CLLocation * location;

@property double minLatitude;
@property double maxLatitude;
@property double minLongitude;
@property double maxLongitude;

+ (CLLocationCoordinate2D) locationWithBearing:(float)bearing distance:(float)distanceMeters fromLocation:(CLLocationCoordinate2D)origin;
- (void) setLatitude:(double)latitude longitude:(double)longitude radius: (double)radius;
-(void)setCoordinate:(CLLocationCoordinate2D)coordinate radius: (double)radius;
+ (instancetype) areaWithCoordinate:(CLLocationCoordinate2D)coordinate radius:(double)radius;
- (instancetype) initWithCoordinate:(CLLocationCoordinate2D)coordinate radius:(double)radius;

@end
