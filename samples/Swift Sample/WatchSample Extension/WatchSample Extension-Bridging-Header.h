//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#if __has_feature(modules)
@import UserNotifications;
#else
#import <UserNotifications/UserNotifications.h>
#endif

@interface MCENotificationDelegate : NSObject <UNUserNotificationCenterDelegate>
@property(class, nonatomic, readonly) MCENotificationDelegate * sharedInstance NS_SWIFT_NAME(shared);
@end
