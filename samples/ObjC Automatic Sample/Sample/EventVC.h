/*
 * Copyright © 2018, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EventVC : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *customEvent;
@property (weak, nonatomic) IBOutlet UISegmentedControl *simulateEvent;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSwitch;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *attributionField;
@property (weak, nonatomic) IBOutlet UITextField *mailingIdField;
@property (weak, nonatomic) IBOutlet UITextField *attributeNameField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *attributeTypeSwitch;
@property (weak, nonatomic) IBOutlet UITextField *attributeValueField;
- (IBAction)sendEvent:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *booleanSwitch;
@property (weak, nonatomic) IBOutlet UILabel *eventStatus;
@property (weak, nonatomic) IBOutlet UIView *booleanContainer;
@property (weak, nonatomic) IBOutlet UISegmentedControl *nameSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * keyboardHeightLayoutConstraint;
- (IBAction) updateTypeSelections:(id)sender;
@end

NS_ASSUME_NONNULL_END
