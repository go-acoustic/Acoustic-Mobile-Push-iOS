//
// Copyright (C) 2024 Acoustic, L.P. All rights reserved.
//
// NOTICE: This file contains material that is confidential and proprietary to
// Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
// industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
// Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
// prohibited.
//

@interface MCESdk (Private)

-(void) sendLocalNotificationWithIdentifier: (NSString*)identifier body: (NSString*)body;


/** This method will reset the current state of the SDK to the installed state. If the autoReinitialize configuration parameter is set to true, the system will register with the server and create a new anonymous user. If the autoReinitialize configuration parameter is set to false the system will not register with the server and the userId and channelId values will be nil until the manualInitialization method is called to begin the registration with the server. */
- (BOOL) invalidateExistingUser;

- (BOOL) invalidateExistingChannel;

@end
