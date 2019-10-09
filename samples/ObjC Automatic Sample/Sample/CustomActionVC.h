/*
 * Copyright © 2019, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#if __has_feature(modules)
@import AcousticMobilePush;
@import UIKit;
#else
#import <AcousticMobilePush/AcousticMobilePush.h>
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CustomActionVC : UIViewController <MCEActionProtocol, UITextFieldDelegate>
- (IBAction)registerCustomAction:(id)sender;
- (IBAction)sendCustomAction:(id)sender;
- (IBAction)unregisterCustomAction:(id)sender;
@property UIToolbar * keyboardDoneButtonView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITextField *typeField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * keyboardHeightLayoutConstraint;
@end

NS_ASSUME_NONNULL_END
