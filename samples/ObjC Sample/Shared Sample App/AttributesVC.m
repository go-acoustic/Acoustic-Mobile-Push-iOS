/*
 * Copyright © 2011, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "AttributesVC.h"
#import "EditCell.h"
#import <objc/runtime.h>
#import "UIColor+Sample.h"
#import "UIColor+data.h"

#if __has_feature(modules)
@import AcousticMobilePush;
#else
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

@interface AttributesVC () {
    NSData * _interfaceState;
    UIDatePicker * datePicker;
    NSDateFormatter * dateFormatter;
    UIToolbar * keyboardDoneButtonView;
    NSNumberFormatter * numberFormatter;
}
@end

@implementation AttributesVC

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder: aDecoder]) {        
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        
        datePicker = [[UIDatePicker alloc] init];
        datePicker.accessibilityIdentifier = @"datePicker";
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        datePicker.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        
        keyboardDoneButtonView = [[UIToolbar alloc] init];
        keyboardDoneButtonView.barStyle = UIBarStyleDefault;
        keyboardDoneButtonView.translucent = YES;
        keyboardDoneButtonView.tintColor = nil;
        
        UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked:)];
        doneButton.accessibilityIdentifier = @"doneButton";
        keyboardDoneButtonView.items = @[ doneButton ];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateUserAttributesError:) name:UpdateUserAttributesError object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateUserAttributesSuccess:) name:UpdateUserAttributesSuccess object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(deleteUserAttributesError:) name:DeleteUserAttributesError object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(deleteUserAttributesSuccess:) name:DeleteUserAttributesSuccess object:nil];
    
        [datePicker addTarget:self action:@selector(dateChanged) forControlEvents:(UIControlEventValueChanged)];
    }
    
    return self;
}

-(void)dateChanged {
    self.valueTextField.text = [dateFormatter stringFromDate:datePicker.date];
}

-(void)deleteUserAttributesSuccess: (NSNotification*)note {
    if(!NSThread.isMainThread) {
        [self performSelectorOnMainThread:@selector(deleteUserAttributesSuccess:) withObject:note waitUntilDone:false];
        return;
    }

    NSArray * keys = note.userInfo[@"keys"];
    [self updateStatus: @{ @"text": [NSString stringWithFormat: @"Deleted User Attributes Named\n\"%@\"", [keys componentsJoinedByString:@"\n"] ], @"color": UIColor.successColor}];
}

-(void)deleteUserAttributesError: (NSNotification*)note {
    if(!NSThread.isMainThread) {
        [self performSelectorOnMainThread:@selector(deleteUserAttributesError:) withObject:note waitUntilDone:false];
        return;
    }

    NSArray * keys = note.userInfo[@"keys"];
    [self updateStatus: @{ @"text": [NSString stringWithFormat: @"Couldn't Delete User Attributes Named\n\"%@\"\nbecause %@", [keys componentsJoinedByString:@"\n"], note.userInfo[@"error"] ], @"color": UIColor.failureColor}];
}

-(void)updateUserAttributesSuccess: (NSNotification*)note {
    if(!NSThread.isMainThread) {
        [self performSelectorOnMainThread:@selector(updateUserAttributesSuccess:) withObject:note waitUntilDone:false];
        return;
    }

    NSMutableArray * keyvalues = [NSMutableArray array];
    for (NSString * key in note.userInfo[@"attributes"] ) {
        [keyvalues addObject: [NSString stringWithFormat: @"%@=%@", key, note.userInfo[@"attributes"][key]]];
    }
    
    [self updateStatus: @{ @"text": [NSString stringWithFormat: @"Updated User Attributes\n%@", [keyvalues componentsJoinedByString:@"\n"] ], @"color": UIColor.successColor}];
}

-(void)updateUserAttributesError: (NSNotification*)note {
    if(!NSThread.isMainThread) {
        [self performSelectorOnMainThread:@selector(updateUserAttributesError:) withObject:note waitUntilDone:false];
        return;
    }

    NSMutableArray * keyvalues = [NSMutableArray array];
    for (NSString * key in note.userInfo[@"attributes"] ) {
        [keyvalues addObject: [NSString stringWithFormat: @"%@=%@", key, note.userInfo[@"attributes"][key]]];
    }
    
    [self updateStatus: @{ @"text": [NSString stringWithFormat: @"Couldn't Update User Attributes\n%@\nbecause %@", [keyvalues componentsJoinedByString:@"\n"], note.userInfo[@"error"] ], @"color": UIColor.failureColor}];
}

-(void) updateStatus: (NSDictionary*) status {
    if(!NSThread.isMainThread) {
        [self performSelectorOnMainThread:@selector(updateStatus:) withObject:status waitUntilDone:false];
        return;
    }
    
    self.statusLabel.textColor = status[@"color"];
    self.statusLabel.text = status[@"text"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateTheme];
}

-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self updateTheme];
}

-(void)updateTheme {
    self.nameTextField.textColor = UIColor.foregroundColor;
    self.valueTextField.textColor = UIColor.foregroundColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.valueTypeControl.accessibilityIdentifier = @"attributeType";
    self.operationTypeControl.accessibilityIdentifier = @"attributeOperation";
    [self updateValueControls];
}

- (IBAction)addQueueTap:(id)sender {
    [self.valueTextField resignFirstResponder];
    [self.nameTextField resignFirstResponder];
    
    NSString * name = self.nameTextField.text;
    NSString * value = self.valueTextField.text;
    
    switch (self.operationTypeControl.selectedSegmentIndex) {
        case UpdateOperation:
            switch (self.valueTypeControl.selectedSegmentIndex) {
                case DateValue:
                {
                    NSDate * dateValue = [NSDate date];
                    if(value && [value respondsToSelector:@selector(isEqualToString:)]) {
                        NSDate * dValue = [dateFormatter dateFromString:value];
                        if(dValue) {
                            dateValue = dValue;
                        }
                    }
                    [self updateStatus: @{@"text": [NSString stringWithFormat: @"Queued User Attribute Update\n%@=%@", name, dateValue], @"color": UIColor.warningColor}];
                    [MCEAttributesQueueManager.sharedInstance updateUserAttributes: @{name: dateValue}];
                    break;
                }
                case StringValue:
                {
                    NSString * stringValue = @"";
                    if(value && [value respondsToSelector:@selector(isEqualToString:)]) {
                        stringValue = value;
                    }
                    
                    [self updateStatus: @{@"text": [NSString stringWithFormat: @"Queued User Attribute Update\n%@=%@", name, stringValue], @"color": UIColor.warningColor}];
                    [MCEAttributesQueueManager.sharedInstance updateUserAttributes: @{name: stringValue}];
                    break;
                }
                case BoolValue:
                {
                    BOOL boolValue = true;
                    if(value && [value respondsToSelector:@selector(isEqualToString:)]) {
                        boolValue = [value boolValue];
                    }
                    
                    [self updateStatus: @{@"text": [NSString stringWithFormat: @"Queued User Attribute Update\n%@=%@", name, @(boolValue)], @"color": UIColor.warningColor}];
                    [MCEAttributesQueueManager.sharedInstance updateUserAttributes: @{name: @(boolValue) }];
                    break;
                }
                case NumberValue:
                {
                    float floatValue = 0;
                    if(value && [value respondsToSelector:@selector(isEqualToString:)]) {
                        floatValue = [value floatValue];
                    }

                    [self updateStatus: @{@"text": [NSString stringWithFormat: @"Queued User Attribute Update\n%@=%f", name, floatValue], @"color": UIColor.warningColor}];
                    [MCEAttributesQueueManager.sharedInstance updateUserAttributes: @{name: @(floatValue)}];
                    break;
                }
            }
            
            break;
        case DeleteOperation:
            [self updateStatus: @{@"text": [NSString stringWithFormat: @"Queued User Attribute Removal\nName \"%@\"", name], @"color": UIColor.warningColor}];
            [MCEAttributesQueueManager.sharedInstance deleteUserAttributes: @[name]];
            break;
    }
}

- (IBAction)valueTypeTap:(id)sender {
    if(@available(iOS 13.0, *)) {
        self.userActivity.needsSave = true;
    }
    
    [NSUserDefaults.standardUserDefaults setObject: self.interfaceState forKey: NSStringFromClass(self.class)];
    [self updateValueControls];
}

-(void)hideAllValueControls {
    self.valueTextField.enabled = false;
    self.valueTextField.alpha = 1;
    self.valueTextField.text = @"No value required for delete operation";
    self.valueTypeControl.enabled = false;
    self.boolSwitch.enabled = false;
    self.boolSwitch.alpha = 0;
    self.booleanView.alpha = 0;
}

-(void)showTextValueControls {
    [self.valueTextField resignFirstResponder];
    self.valueTextField.enabled = true;
    self.valueTextField.alpha = 1;
    self.valueTypeControl.enabled = true;
    self.boolSwitch.enabled = false;
    self.boolSwitch.alpha = 0;
    self.booleanView.alpha = 0;
}

-(void)showBoolValueControls {
    self.valueTextField.enabled = false;
    self.valueTextField.alpha = 0;
    self.valueTypeControl.enabled = true;
    self.boolSwitch.enabled = true;
    self.boolSwitch.alpha = 1;
    self.booleanView.alpha = 1;
}

-(void)updateValueControls {
    switch (self.operationTypeControl.selectedSegmentIndex) {
        case UpdateOperation:
            switch (self.valueTypeControl.selectedSegmentIndex) {
                case BoolValue:
                {
                    [self showBoolValueControls];
                    break;
                }
                case DateValue:
                {
                    [self showTextValueControls];
                    self.valueTextField.text = [dateFormatter stringFromDate:datePicker.date];
                    break;
                }
                case StringValue:
                {
                    [self showTextValueControls];
                    self.valueTextField.keyboardType = UIKeyboardTypeDefault;
                    break;
                }
                case NumberValue:
                {
                    self.valueTextField.keyboardType = UIKeyboardTypeDecimalPad;
                    [self showTextValueControls];
                    self.valueTextField.text = [@([self.valueTextField.text floatValue]) stringValue];
                    break;
                }
            }
            break;
        case DeleteOperation:
            [self hideAllValueControls];
            break;
    }
}

- (IBAction)operationTypeTap:(id)sender {
    if(@available(iOS 13.0, *)) {
        self.userActivity.needsSave = true;
    }

    [NSUserDefaults.standardUserDefaults setObject:self.interfaceState forKey: NSStringFromClass(self.class)];
    [self updateValueControls];
}

-(IBAction)boolValueChanged: (id)sender {
    [NSUserDefaults.standardUserDefaults setObject:self.interfaceState forKey: NSStringFromClass(self.class)];
}

-(void) doneClicked: (id)sender {
    if(self.valueTextField.isFirstResponder) {
        [self.valueTextField resignFirstResponder];
    } else if(self.nameTextField.isFirstResponder) {
        [self.nameTextField resignFirstResponder];
    }
    [NSUserDefaults.standardUserDefaults setObject:self.interfaceState forKey: NSStringFromClass(self.class)];
}

// UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [NSUserDefaults.standardUserDefaults setObject:self.interfaceState forKey: NSStringFromClass(self.class)];
    return false;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if([textField isEqual: self.valueTextField]) {
        if(self.valueTypeControl.selectedSegmentIndex == DateValue) {
            self.valueTextField.inputView = datePicker;
        } else {
            self.valueTextField.inputView = nil;
        }
    }
    textField.inputAccessoryView = keyboardDoneButtonView;
    [keyboardDoneButtonView sizeToFit];
}

// Generic State Restoration
-(void)setInterfaceState: (NSData*) interfaceState {
    _interfaceState = interfaceState;
}

// Generic State Restoration
-(NSData*)interfaceState {
    NSMutableDictionary * userInfo = [@{
        @"valueText": self.valueTextField.text,
        @"nameText": self.nameTextField.text,
        @"valueDate": datePicker.date,
        @"valueType": @(self.valueTypeControl.selectedSegmentIndex),
        @"operationType": @(self.operationTypeControl.selectedSegmentIndex),
        @"valueBool": @(self.boolSwitch.on),
        @"statusText": self.statusLabel.text,
        @"statusColor": self.statusLabel.textColor.data
    } mutableCopy];
    
    if(self.valueTextField.isFirstResponder) {
        userInfo[@"editingField"] = @"valueTextField";
        userInfo[@"editingValue"] = self.valueTextField.text;
    } else if(self.nameTextField.isFirstResponder) {
        userInfo[@"editingField"] = @"nameTextField";
        userInfo[@"editingValue"] = self.nameTextField.text;
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

    self.valueTextField.text = interfaceState[@"valueText"] ? interfaceState[@"valueText"] : @"";
    self.nameTextField.text = interfaceState[@"nameText"] ? interfaceState[@"nameText"] : @"";
    datePicker.date = interfaceState[@"valueDate"] ? interfaceState[@"valueDate"] : [NSDate date];
    self.valueTypeControl.selectedSegmentIndex = [interfaceState[@"valueType"] integerValue];
    self.operationTypeControl.selectedSegmentIndex = [interfaceState[@"operationType"] integerValue];
    self.boolSwitch.on = [interfaceState[@"valueBool"] boolValue];

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
-(void)updateUserActivityState:(NSUserActivity *)activity {
    [super updateUserActivityState:activity];
    NSData * interfaceState = self.interfaceState;
    if(interfaceState && [interfaceState respondsToSelector:@selector(isEqualToData:)]) {
        [activity addUserInfoEntriesFromDictionary: @{@"interfaceState": interfaceState}];
    }
}

// State Restoration and Multiple Window Support iOS ≥13
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
}

@end
