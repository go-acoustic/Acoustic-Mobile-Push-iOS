/*
 * Copyright © 2018, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "EventVC.h"
#import "AttributesVC.h"
#import "UIColor+Sample.h"
#import "UIColor+data.h"

#if __has_feature(modules)
@import AcousticMobilePush;
#else
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif


typedef enum : NSUInteger {
    CustomEvent,
    SimulateEvent
} EventType;

typedef enum : NSUInteger {
    AppEvent,
    ActionEvent,
    InboxEvent,
    GeofenceEvent,
    iBeaconEvent
} SimulatedEvents;

@interface EventVC () {
    UIDatePicker * datePicker;
    NSDateFormatter * dateFormatter;
    UIToolbar * keyboardDoneButtonView;
    NSNumberFormatter * numberFormatter;
    NSData * _interfaceState;
}

@end

@implementation EventVC

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
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sendEventSuccess:) name:MCEEventSuccess object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sendEventFailure:) name:MCEEventFailure object:nil];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    
    return self;
}

-(void)keyboardNotification:(NSNotification*)note {
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
}

-(void) doneClicked: (id)sender {
     if(self.nameField.isFirstResponder) {
         [self.nameField resignFirstResponder];
     } else if(self.attributionField.isFirstResponder) {
         [self.attributionField resignFirstResponder];
     } else if(self.mailingIdField.isFirstResponder) {
         [self.mailingIdField resignFirstResponder];
     } else if(self.attributeNameField.isFirstResponder) {
         [self.attributeNameField resignFirstResponder];
     } else if(self.attributeValueField.isFirstResponder) {
         if(self.attributeTypeSwitch.selectedSegmentIndex == DateValue) {
             self.attributeValueField.text = [dateFormatter stringFromDate: datePicker.date];
         }
         [self.attributeValueField resignFirstResponder];
     }
}

-(void)sendEventFailure:(NSNotification*)note {
    NSDictionary * events = note.userInfo[@"events"];
    NSError * error = note.userInfo[@"error"];
    NSMutableArray * eventStrings = [NSMutableArray array];
    for(MCEEvent * event in events) {
        [eventStrings addObject: [NSString stringWithFormat: @"name: %@, type: %@", event.name, event.type]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateStatus: @{@"color": UIColor.failureColor, @"text": [NSString stringWithFormat: @"Couldn't send events: %@, because: %@", [eventStrings componentsJoinedByString:@","], error]}];
    });
}

-(void)sendEventSuccess:(NSNotification*)note {
    NSDictionary * events = note.userInfo[@"events"];
    NSMutableArray * eventStrings = [NSMutableArray array];
    for(MCEEvent * event in events) {
        [eventStrings addObject: [NSString stringWithFormat: @"name: %@, type: %@", event.name, event.type]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateStatus: @{@"color": UIColor.successColor, @"text": [NSString stringWithFormat: @"Sent events: %@", [eventStrings componentsJoinedByString:@","]]}];
    });
}

-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self updateTheme];
}

-(void)updateTheme {
    self.nameField.textColor = UIColor.foregroundColor;
    self.attributionField.textColor = UIColor.foregroundColor;
    self.mailingIdField.textColor = UIColor.foregroundColor;
    self.attributeNameField.textColor = UIColor.foregroundColor;
    self.attributeValueField.textColor = UIColor.foregroundColor;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self updateTheme];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.customEvent.accessibilityIdentifier = @"customEvent";
    self.simulateEvent.accessibilityIdentifier = @"simulateEvent";
    self.typeSwitch.accessibilityIdentifier = @"typeSwitch";
    self.attributeTypeSwitch.accessibilityIdentifier = @"attributeTypeSwitch";
    self.nameSwitch.accessibilityIdentifier = @"nameSwitch";
}

-(void)sendEvent:(id)sender {
    NSString * name = nil;
    NSString * type = nil;
    NSString * attribution = self.attributionField.text.length ? self.attributionField.text : nil;
    NSString * mailingId = self.mailingIdField.text.length ? self.mailingIdField.text : nil;
    
    [self doneClicked: self];
    if(self.customEvent.selectedSegmentIndex < 0) {
        self.customEvent.selectedSegmentIndex = 0;
    }
    switch(self.customEvent.selectedSegmentIndex) {
        case CustomEvent:
            type = @"custom";
            name = self.nameField.text.length ? self.nameField.text : nil;
            break;
        case SimulateEvent:
            if(self.typeSwitch.selectedSegmentIndex < 0) {
                self.typeSwitch.selectedSegmentIndex = 0;
            }
            if(self.typeSwitch.selectedSegmentIndex != UISegmentedControlNoSegment) {
                type = [self.typeSwitch titleForSegmentAtIndex: self.typeSwitch.selectedSegmentIndex];
            }
            
            if(self.nameSwitch.selectedSegmentIndex < 0) {
                self.nameSwitch.selectedSegmentIndex = 0;
            }
            if(self.nameSwitch.selectedSegmentIndex != UISegmentedControlNoSegment) {
                name = [self.nameSwitch titleForSegmentAtIndex: self.nameSwitch.selectedSegmentIndex];
            }
            break;
    }
    
    NSDictionary * attributes = nil;
    NSString * attributeValue = self.attributeValueField.text;
    NSString * attributeName = self.attributeNameField.text;
    if(attributeName.length) {
        if(self.attributeTypeSwitch.selectedSegmentIndex < 0) {
            self.attributeTypeSwitch.selectedSegmentIndex = 0;
        }
        switch (self.attributeTypeSwitch.selectedSegmentIndex) {
            case DateValue: {
                NSDate * date = [dateFormatter dateFromString: attributeValue];
                if(date) {
                    attributes = @{attributeName: date};
                }
                break;
            }
            case StringValue: {
                if(attributeValue.length) {
                    attributes = @{attributeName: attributeValue};
                }
                break;
            }
            case NumberValue: {
                NSNumber * number = [numberFormatter numberFromString: attributeValue];
                if(number) {
                    attributes = @{attributeName: number};
                }
                break;
            }
            case BoolValue: {
                NSNumber * number = @(self.booleanSwitch.on);
                attributes = @{attributeName: number};
                break;
            }
        }
    }

    if(name && type) {
        MCEEvent * event = [[MCEEvent alloc] initWithName:name type:type timestamp:nil attributes:attributes attribution:attribution mailingId:mailingId];
        [MCEEventService.sharedInstance addEvent:event immediate:TRUE];
        [self updateStatus: @{@"color": UIColor.warningColor, @"text": [NSString stringWithFormat: @"Queued Event with name: %@, type: %@", name, type]}];
    }
}

-(void) updateStatus: (NSDictionary*) status {
    if(!NSThread.isMainThread) {
        [self performSelectorOnMainThread:@selector(updateStatus:) withObject:status waitUntilDone:false];
        return;
    }
    
    self.eventStatus.textColor = status[@"color"];
    self.eventStatus.text = status[@"text"];
}

- (IBAction) updateTypeSelections:(id)sender {
    if(@available(iOS 13.0, *)) {
        self.userActivity.needsSave = true;
    }
    
    [NSUserDefaults.standardUserDefaults setObject:self.interfaceState forKey: NSStringFromClass(self.class)];
    
    [self.attributeTypeSwitch setEnabled: true];
    [self.attributeNameField setEnabled: true];
    [self.attributeValueField setEnabled: true];
    [self.booleanSwitch setEnabled: true];

    [self doneClicked: self];
    for(int i=0; i<self.attributeTypeSwitch.numberOfSegments;i++) {
        [self.attributeTypeSwitch setEnabled:true forSegmentAtIndex:i];
    }

    if(self.customEvent.selectedSegmentIndex < 0) {
        self.customEvent.selectedSegmentIndex = 0;
    }
    
    switch(self.customEvent.selectedSegmentIndex) {
        case CustomEvent:
            self.nameSwitch.hidden = TRUE;
            self.nameField.hidden = FALSE;
            self.simulateEvent.enabled = FALSE;
            [self updateTypeSegments:@[@"custom"]];
            break;
        case SimulateEvent:
            self.nameField.hidden = TRUE;
            self.nameSwitch.hidden = FALSE;
            self.simulateEvent.enabled = TRUE;

            if(self.simulateEvent.selectedSegmentIndex < 0) {
                self.simulateEvent.selectedSegmentIndex = 0;
            }
            
            switch (self.simulateEvent.selectedSegmentIndex) {
                case AppEvent:
                    [self updateTypeSegments:@[@"application"]];
                    [self updateNameSegments:@[@"sessionStarted", @"sessionEnded", @"uiPushEnabled", @"uiPushDisabled"]];
                    
                    if(self.nameSwitch.selectedSegmentIndex < 0) {
                        self.nameSwitch.selectedSegmentIndex = 0;
                    }
                    switch(self.nameSwitch.selectedSegmentIndex) {
                        case 0:
                            [self allowNoAttributes];
                            break;
                        case 1:
                            self.attributeNameField.text = @"sessionLength";
                            [self onlyAllowNumberAttributes];
                            break;
                        case 2:
                        case 3:
                            [self allowNoAttributes];
                            break;
                    }
                    break;
                case ActionEvent:
                    [self updateTypeSegments:@[SimpleNotificationSource, InboxSource, InAppSource]];
                    [self updateNameSegments:@[@"urlClicked", @"appOpened", @"phoneNumberClicked", @"inboxMessageOpened"]];

                    if(self.nameSwitch.selectedSegmentIndex < 0) {
                        self.nameSwitch.selectedSegmentIndex = 0;
                    }

                    switch(self.nameSwitch.selectedSegmentIndex) {
                        case 0: // urlClicked
                            [self onlyAllowStringAttributes];
                            self.attributeNameField.text = @"url";
                            break;
                        case 1: // appOpened
                            [self allowNoAttributes];
                            break;
                        case 2: // phoneNumberClicked
                            [self onlyAllowNumberAttributes];
                            self.attributeNameField.text = @"phoneNumber";
                            break;
                        case 3: // inboxMessageOpened
                            [self onlyAllowStringAttributes];
                            self.attributeNameField.text = @"richContentId";
                            break;
                    }
                    break;
                case InboxEvent:
                    [self updateTypeSegments:@[@"inbox"]];
                    [self updateNameSegments:@[@"messageOpened"]];
                    [self onlyAllowStringAttributes];
                    self.attributeNameField.text = @"inboxMessageId";
                    break;
                case GeofenceEvent:
                    [self updateTypeSegments:@[@"geofence"]];
                    [self updateNameSegments:@[@"disabled", @"enabled", @"enter", @"exit"]];
                    break;
                case iBeaconEvent:
                    [self updateTypeSegments:@[@"ibeacon"]];
                    [self updateNameSegments:@[@"disabled", @"enabled", @"enter", @"exit"]];
                    break;
            }
            
            if(self.simulateEvent.selectedSegmentIndex == GeofenceEvent || self.simulateEvent.selectedSegmentIndex == iBeaconEvent) {
                if(self.nameSwitch.selectedSegmentIndex < 0) {
                    self.nameSwitch.selectedSegmentIndex = 0;
                }

                switch(self.nameSwitch.selectedSegmentIndex) {
                    case 0: // disabled
                        [self onlyAllowStringAttributes];
                        self.attributeNameField.text = @"reason";
                        self.attributeValueField.text = @"not_enabled";
                        break;
                    case 1: // enabled
                        [self allowNoAttributes];
                        break;
                    case 2: // enter
                    case 3: // exit
                        [self onlyAllowStringAttributes];
                        self.attributeNameField.text = @"locationId";
                        break;
                }
            }
    }
    
    if(self.attributeTypeSwitch.selectedSegmentIndex < 0) {
        self.attributeTypeSwitch.selectedSegmentIndex = 0;
    }

    switch (self.attributeTypeSwitch.selectedSegmentIndex) {
        case DateValue:
            self.attributeValueField.hidden = FALSE;
            self.booleanContainer.hidden = TRUE;
            if(![dateFormatter dateFromString: self.attributeValueField.text]) {
                self.attributeValueField.text = @"";
            }
            break;
        case StringValue:
            self.attributeValueField.keyboardType = UIKeyboardTypeDefault;
            self.attributeValueField.hidden = FALSE;
            self.booleanContainer.hidden = TRUE;
            break;
        case NumberValue:
            self.attributeValueField.keyboardType = UIKeyboardTypeDecimalPad;
            self.attributeValueField.hidden = FALSE;
            self.booleanContainer.hidden = TRUE;
            if(![numberFormatter numberFromString:self.attributeValueField.text]) {
                self.attributeValueField.text = @"";
            }
            break;
        case BoolValue:
            self.attributeValueField.hidden = TRUE;
            self.booleanContainer.hidden = FALSE;
            break;
    }
    
    [self.view layoutSubviews];
}

-(void)allowNoAttributes {
    self.attributeNameField.text = @"";
    self.attributeValueField.text = @"";
    [self allowOnlyAttributeType: UISegmentedControlNoSegment];
    [self.attributeNameField setEnabled:false];
    [self.attributeTypeSwitch setEnabled:false];
    [self.attributeValueField setEnabled: false];
    [self.booleanSwitch setEnabled: false];

    for(int i=0; i<self.attributeTypeSwitch.numberOfSegments;i++) {
        [self.attributeTypeSwitch setEnabled:false forSegmentAtIndex:i];
    }
}

-(void)allowOnlyAttributeType: (int)allowed {
    for(int i=0; i<self.attributeTypeSwitch.numberOfSegments;i++) {
        if(i == allowed) {
            [self.attributeTypeSwitch setEnabled:true forSegmentAtIndex:i];
        } else {
            [self.attributeTypeSwitch setEnabled:false forSegmentAtIndex:i];
        }
    }
}

-(void)onlyAllowStringAttributes {
    [self.attributeTypeSwitch setEnabled:false];
    [self.attributeNameField setEnabled: true];
    [self.booleanSwitch setEnabled: false];
    self.attributeTypeSwitch.selectedSegmentIndex = StringValue;
    [self allowOnlyAttributeType: StringValue];
}

-(void)onlyAllowNumberAttributes {
    [self.attributeTypeSwitch setEnabled:false];
    [self.attributeNameField setEnabled: true];
    [self.booleanSwitch setEnabled: false];
    self.attributeTypeSwitch.selectedSegmentIndex = NumberValue;
    [self allowOnlyAttributeType: NumberValue];
}

-(void)updateNameSegments: (NSArray*) names {
    [self update: self.nameSwitch segments: names];
}

-(void)updateTypeSegments: (NSArray*) types {
    [self update: self.typeSwitch segments: types];
}

-(void)resize: (UISegmentedControl*)control segmentCount: (NSInteger) count {
    while(control.numberOfSegments > count) {
        [control removeSegmentAtIndex:0 animated:FALSE];
    }
    while(control.numberOfSegments < count) {
        [control insertSegmentWithTitle:@"" atIndex:0 animated:FALSE];
    }
}

-(void)update: (UISegmentedControl*)control segments: (NSArray*) segments {
    [self resize:control segmentCount:segments.count];
    NSUInteger index = 0;
    for(NSString * segment in segments) {
        [control setTitle:segment forSegmentAtIndex:index++];
    }
    
    NSUInteger selected = control.selectedSegmentIndex;
    if(selected == UISegmentedControlNoSegment || selected > segments.count - 1) {
        selected = 0;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        control.selectedSegmentIndex = UISegmentedControlNoSegment;
        dispatch_async(dispatch_get_main_queue(), ^{
            control.selectedSegmentIndex = selected;
        });
    });
}


// UITextFieldDelegate Methods
- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason {
    if(reason != UITextFieldDidEndEditingReasonCommitted) {
        return;
    }
    
    if([textField isEqual: self.attributionField]) {
        [NSUserDefaults.standardUserDefaults setObject:textField.text forKey:@"attributionField"];
    } else if([textField isEqual: self.mailingIdField]) {
        [NSUserDefaults.standardUserDefaults setObject:textField.text forKey:@"mailingIdField"];
    } else if([textField isEqual: self.attributeValueField]) {
        [NSUserDefaults.standardUserDefaults setObject:textField.text forKey:@"attributeValueField"];
    } else if([textField isEqual: self.attributeNameField]) {
        [NSUserDefaults.standardUserDefaults setObject:textField.text forKey:@"attributeNameField"];
    } else if([textField isEqual: self.nameField]) {
        [NSUserDefaults.standardUserDefaults setObject:textField.text forKey:@"nameField"];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if([textField isEqual: self.attributeValueField]) {
        if(self.attributeTypeSwitch.selectedSegmentIndex == DateValue) {
            self.attributeValueField.inputView = datePicker;
        } else {
            self.attributeValueField.inputView = nil;
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
        @"attribution": self.attributionField.text ? self.attributionField.text : @"",
        @"mailingId": self.mailingIdField.text ? self.mailingIdField.text : @"",
        @"attributeValue": self.attributeValueField.text ? self.attributeValueField.text : @"",
        @"attributeName": self.attributeNameField.text ? self.attributeNameField.text : @"",
        @"name": self.nameField.text ? self.nameField.text : @"",
        @"boolean": @(self.booleanSwitch.on),
        @"customEventSelection": @(self.customEvent.selectedSegmentIndex),
        @"simulateEventSelection": @(self.simulateEvent.selectedSegmentIndex),
        @"typeSelection": @(self.typeSwitch.selectedSegmentIndex),
        @"typeLength": @(self.typeSwitch.numberOfSegments),
        @"nameSelection": @(self.nameSwitch.selectedSegmentIndex),
        @"nameLength": @(self.nameSwitch.numberOfSegments),
        @"attributeTypeSelection": @(self.attributeTypeSwitch.selectedSegmentIndex)
    } mutableCopy];
    
    if(self.attributionField.isFirstResponder) {
        userInfo[@"editingField"] = @"attributionField";
        userInfo[@"editingValue"] = self.attributionField.text;
    } else if(self.mailingIdField.isFirstResponder) {
        userInfo[@"editingField"] = @"mailingIdField";
        userInfo[@"editingValue"] = self.mailingIdField.text;
    } else if(self.attributeValueField.isFirstResponder) {
        userInfo[@"editingField"] = @"attributeValueField";
        userInfo[@"editingValue"] = self.attributeValueField.text;
    } else if(self.attributeNameField.isFirstResponder) {
        userInfo[@"editingField"] = @"attributeNameField";
        userInfo[@"editingValue"] = self.attributeNameField.text;
    } else if(self.nameField.isFirstResponder) {
        userInfo[@"editingField"] = @"nameField";
        userInfo[@"editingValue"] = self.nameField.text;
    }
    userInfo[@"statusText"] = self.eventStatus.text;
    userInfo[@"statusColor"] = self.eventStatus.textColor.data;

    NSError * error = nil;
    NSData * data = [NSPropertyListSerialization dataWithPropertyList:userInfo format: NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    if(error) {
        NSLog(@"Can't encode interface state as data");
        return nil;
    }
    return data;
}

// Generic State Restoration
-(void)restoreInterfaceStateIfAvailable {
    if(!_interfaceState) {
        [self updateTypeSelections: self];
        return;
    }

    NSError * error = nil;
    NSDictionary * interfaceState = [NSPropertyListSerialization propertyListWithData:_interfaceState options:0 format:nil error:&error];
    if(error) {
        NSLog(@"can't decode interface state %@", error.localizedDescription);
        return;
    }

    self.attributionField.text = interfaceState[@"attribution"];
    self.mailingIdField.text = interfaceState[@"mailingId"];
    self.attributeValueField.text = interfaceState[@"attributeValue"];
    self.attributeNameField.text = interfaceState[@"attributeName"];
    self.nameField.text = interfaceState[@"name"];
    
    self.booleanSwitch.on = [interfaceState[@"boolean"] boolValue];
    self.customEvent.selectedSegmentIndex = [interfaceState[@"customEventSelection"] integerValue];
    self.simulateEvent.selectedSegmentIndex = [interfaceState[@"simulateEventSelection"] integerValue];
    
    [self resize:self.typeSwitch segmentCount:[interfaceState[@"typeLength"] integerValue]];
    self.typeSwitch.selectedSegmentIndex = [interfaceState[@"typeSelection"] integerValue];

    [self resize:self.nameSwitch segmentCount:[interfaceState[@"nameLength"] integerValue]];
    self.nameSwitch.selectedSegmentIndex = [interfaceState[@"nameSelection"] integerValue];
    self.attributeTypeSwitch.selectedSegmentIndex = [interfaceState[@"attributeTypeSelection"] integerValue];
    
    self.eventStatus.text = interfaceState[@"statusText"] ? interfaceState[@"statusText"] : @"No status yet";
    self.eventStatus.textColor = interfaceState[@"statusColor"] ? [UIColor from: interfaceState[@"statusColor"]] : UIColor.disabledColor;
    
    [self updateTypeSelections: self];
    NSString * editingField = interfaceState[@"editingField"];
    NSString * editingValue = interfaceState[@"editingValue"];
    if(editingField && [editingField respondsToSelector:@selector(isEqualToString:)] && editingValue && [editingValue respondsToSelector:@selector(isEqualToString:)]) {
        if([editingField isEqual:@"attributionField"]) {
            self.attributionField.text = editingValue;
            [self.attributionField becomeFirstResponder];
        } else if([editingField isEqual:@"mailingIdField"]) {
            self.mailingIdField.text = editingValue;
            [self.mailingIdField becomeFirstResponder];
        } else if([editingField isEqual:@"attributeValueField"]) {
            self.attributeValueField.text = editingValue;
            [self.attributeValueField becomeFirstResponder];
        } else if([editingField isEqual:@"attributeNameField"]) {
            self.attributeNameField.text = editingValue;
            [self.attributeNameField becomeFirstResponder];
        } else if([editingField isEqual:@"nameField"]) {
            self.nameField.text = editingValue;
            [self.nameField becomeFirstResponder];
        }
    }
    
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

@end
