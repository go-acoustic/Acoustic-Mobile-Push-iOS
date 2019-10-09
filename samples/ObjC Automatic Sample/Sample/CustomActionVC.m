/*
 * Copyright © 2019, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "CustomActionVC.h"
#import "UIColor+Sample.h"

#if __has_feature(modules)
@import AcousticMobilePush;
#else
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

NSString * customActionUserDefaultKey = @"customActions";
NSString * typeUserDefaultKey = @"customActionType";
NSString * valueUserDefaultKey = @"customActionValue";

@interface CustomActionVC ()
@property NSMutableArray * registeredTypes;
@end

@implementation CustomActionVC

-(void)viewWillAppear:(BOOL)animated {
    self.registeredTypes = [NSMutableArray array];
    [super viewWillAppear:animated];
    [self updateTheme];
    
    for (NSString * type in [NSUserDefaults.standardUserDefaults stringArrayForKey: customActionUserDefaultKey]) {
        [MCEActionRegistry.sharedInstance registerTarget:self withSelector:@selector(receiveCustomAction:) forAction: type];
    }
    
    self.typeField.text = [NSUserDefaults.standardUserDefaults stringForKey: typeUserDefaultKey];
    self.valueField.text = [NSUserDefaults.standardUserDefaults stringForKey: valueUserDefaultKey];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    for (NSString * type in self.registeredTypes) {
        [MCEActionRegistry.sharedInstance unregisterAction: type];
    }
    [self.registeredTypes removeAllObjects];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.keyboardDoneButtonView = [[UIToolbar alloc] init];
    self.keyboardDoneButtonView.barStyle = UIBarStyleDefault;
    self.keyboardDoneButtonView.translucent = YES;
    self.keyboardDoneButtonView.tintColor = nil;
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked:)];
    doneButton.accessibilityIdentifier = @"doneButton";
    self.keyboardDoneButtonView.items = @[ doneButton ];
    
    [NSNotificationCenter.defaultCenter addObserverForName:MCECustomPushNotYetRegistered object:nil queue: NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary * action = note.userInfo[@"action"];
        self.statusLabel.textColor = UIColor.warningColor;
        self.statusLabel.text = [NSString stringWithFormat: @"Previously Registered Custom Action Received: %@", action];
    }];

    [NSNotificationCenter.defaultCenter addObserverForName:MCECustomPushNotRegistered object:nil queue: NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary * action = note.userInfo[@"action"];
        self.statusLabel.textColor = UIColor.failureColor;
        self.statusLabel.text = [NSString stringWithFormat: @"Unregistered Custom Action Received: %@", action];
    }];

    [NSNotificationCenter.defaultCenter addObserverForName:UIKeyboardWillChangeFrameNotification object:nil queue: NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        CGRect endFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        NSTimeInterval duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationOptions options = [note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        if(endFrame.origin.y >= UIScreen.mainScreen.bounds.size.height) {
            self.keyboardHeightLayoutConstraint.constant = 0.0;
        } else {
            self.keyboardHeightLayoutConstraint.constant = endFrame.size.height;
        }
        
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }];
}

-(void) doneClicked: (id)sender {
    [self.typeField resignFirstResponder];
    [self.valueField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.inputAccessoryView = self.keyboardDoneButtonView;
    [self.keyboardDoneButtonView sizeToFit];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [NSUserDefaults.standardUserDefaults setObject: self.typeField.text forKey: typeUserDefaultKey];
    [NSUserDefaults.standardUserDefaults setObject: self.valueField.text forKey: valueUserDefaultKey];
}

// This method simulates how custom actions receive push actions
-(void)receiveCustomAction:(NSDictionary *) action {
    if(![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self receiveCustomAction: action];
        });
        return;
    }

    if([self.registeredTypes containsObject: action[@"type"]]) {
        self.statusLabel.textColor = UIColor.successColor;
        self.statusLabel.text = [NSString stringWithFormat: @"Received Custom Action: %@", action];
    } else {
        self.statusLabel.textColor = UIColor.warningColor;
        self.statusLabel.text = [NSString stringWithFormat: @"Previously Registered Custom Action Received: %@", action];
    }
}

// This method simulates a custom action registering to receive push actions
- (IBAction)registerCustomAction:(id)sender {
    NSMutableSet * customActions = [NSMutableSet setWithArray: [NSUserDefaults.standardUserDefaults stringArrayForKey:customActionUserDefaultKey]];
    [customActions addObject:self.typeField.text];
    [NSUserDefaults.standardUserDefaults setObject: [customActions allObjects] forKey: customActionUserDefaultKey];
    
    [self.registeredTypes addObject: self.typeField.text];
    self.statusLabel.textColor = UIColor.successColor;
    self.statusLabel.text = [NSString stringWithFormat: @"Registering Custom Action: %@", self.typeField.text];
    [MCEActionRegistry.sharedInstance registerTarget:self withSelector:@selector(receiveCustomAction:) forAction:self.typeField.text];
}

// This method simulates a user clicking on a push message with a custom action
- (IBAction)sendCustomAction:(id)sender {
    NSDictionary * action = @{@"type": self.typeField.text, @"value": self.valueField.text};
    NSDictionary * payload = @{@"notification-action": action};
    self.statusLabel.textColor = UIColor.successColor;
    self.statusLabel.text = [NSString stringWithFormat: @"Sending Custom Action: %@", action];
    [MCEActionRegistry.sharedInstance performAction:action forPayload:payload source:@"internal" attributes:nil userText:nil];
}

// This method shows how to unregister a custom action
- (IBAction)unregisterCustomAction:(id)sender {
    self.statusLabel.textColor = UIColor.successColor;
    self.statusLabel.text = [NSString stringWithFormat: @"Unregistered Action: %@", self.typeField.text];
    [MCEActionRegistry.sharedInstance unregisterAction:self.typeField.text];
}

-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self updateTheme];
}

-(void)updateTheme {
    if(![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateTheme];
        });
        return;
    }
    self.typeField.textColor = UIColor.foregroundColor;
    self.valueField.textColor = UIColor.foregroundColor;
}

@end
