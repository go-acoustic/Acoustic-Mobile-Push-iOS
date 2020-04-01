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
#import "UIColor+data.h"

#if __has_feature(modules)
@import AcousticMobilePush;
#else
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

NSString * customActionUserDefaultKey = @"customActions";
NSString * typeUserDefaultKey = @"customActionType";
NSString * valueUserDefaultKey = @"customActionValue";

@interface CustomActionVC () {
    NSData * _interfaceState;
}
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
    [self registerCustomActionString: self.typeField.text];
}
- (void)registerCustomActionString:(NSString*)string {
    NSMutableSet * customActions = [NSMutableSet setWithArray: [NSUserDefaults.standardUserDefaults stringArrayForKey:customActionUserDefaultKey]];
    [customActions addObject: string];
    [NSUserDefaults.standardUserDefaults setObject: [customActions allObjects] forKey: customActionUserDefaultKey];
    
    [self.registeredTypes addObject: string];
    self.statusLabel.textColor = UIColor.successColor;
    self.statusLabel.text = [NSString stringWithFormat: @"Registering Custom Action: %@", string];
    [MCEActionRegistry.sharedInstance registerTarget:self withSelector:@selector(receiveCustomAction:) forAction:string];
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

// Generic State Restoration
-(void)setInterfaceState: (NSData*) interfaceState {
    _interfaceState = interfaceState;
}

// Generic State Restoration
-(NSData*)interfaceState {
    NSMutableDictionary * userInfo = [@{
        @"typeField": self.typeField.text,
        @"valueField": self.valueField.text,
        @"statusText": self.statusLabel.text,
        @"statusColor": self.statusLabel.textColor.data,
        @"registeredTypes": self.registeredTypes
    } mutableCopy];
    
    if(self.typeField.isFirstResponder) {
        userInfo[@"editingField"] = @"typeField";
        userInfo[@"editingValue"] = self.typeField.text;
    } else if(self.valueField.isFirstResponder) {
        userInfo[@"editingField"] = @"valueField";
        userInfo[@"editingValue"] = self.valueField.text;
    }
    
    NSError * error = nil;
    NSData * data = [NSPropertyListSerialization dataWithPropertyList:userInfo format: NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    if(error) {
        NSLog(@"Can't encode interface state as data");
        return nil;
    }
    return data;
}

-(void)restoreInterfaceStateIfAvailable {
    if(!_interfaceState) {
        return;
    }
    
    NSError * error = nil;
    NSDictionary * interfaceState = [NSPropertyListSerialization propertyListWithData:_interfaceState options:0 format:nil error:&error];
    if(error) {
        NSLog(@"can't decode interface state %@", error.localizedDescription);
        return;
    }
    
    for(NSString * string in interfaceState[@"registeredTypes"]) {
        [self registerCustomActionString: string];
    }
    
    self.typeField.text = interfaceState[@"typeField"] ? interfaceState[@"typeField"] : @"";
    self.valueField.text = interfaceState[@"valueField"] ? interfaceState[@"valueField"] : @"";

    self.statusLabel.text = interfaceState[@"statusText"] ? interfaceState[@"statusText"] : @"No status yet";
    self.statusLabel.textColor = interfaceState[@"statusColor"] ? [UIColor from: interfaceState[@"statusColor"]] : UIColor.disabledColor;
    
    _interfaceState = nil;
}

// State Restoration and Multiple Window Support iOS ≥13
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self restoreInterfaceStateIfAvailable];
}

// State Restoration and Multiple Window Support iOS ≥13
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    for (NSString * type in self.registeredTypes) {
        [MCEActionRegistry.sharedInstance unregisterAction: type];
    }
    [self.registeredTypes removeAllObjects];
}


@end
