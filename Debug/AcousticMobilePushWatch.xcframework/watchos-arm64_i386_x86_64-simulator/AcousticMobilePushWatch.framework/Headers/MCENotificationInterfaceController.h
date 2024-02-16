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
@import WatchKit;
#else
#import <WatchKit/WatchKit.h>
#endif

@interface MCENotificationInterfaceController : WKUserNotificationInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceImage *headerImage;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceMap *mapView;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *backgroundGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *bodyLabel;

@end
