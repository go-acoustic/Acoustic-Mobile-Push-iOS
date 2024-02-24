//
// Copyright (C) 2024 Acoustic, L.P. All rights reserved.
//
// NOTICE: This file contains material that is confidential and proprietary to
// Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
// industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
// Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
// prohibited.
//

@class MCETaskQueue;
@class MCEInboxMessage;
@class MCEInAppMessage;

@interface MCEInboxQueueManager(Private)

- (MCETaskQueue*) inboxQueue;
- (void) updateViewCountForInAppMessage: (MCEInAppMessage*) inAppMessage;
- (void) updateReadStatusForInboxMessage: (MCEInboxMessage*) inboxMessage;
- (void) updateDeleteStatusForInboxMessage: (MCEInboxMessage*) inboxMessage;
- (BOOL) clearQueue;
- (void) stopQueue;
- (void) startQueue;
@end
