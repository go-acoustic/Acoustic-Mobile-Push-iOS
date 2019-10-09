/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#if __has_feature(modules)
@import UIKit;
#else
#import <UIKit/UIKit.h>
#endif

/** The MCEInboxTableViewController class handles all the details of pulling data from the database and displaying previews through a UITableView and full content through UIViewControllers. It can be used as the class of a UITableViewController to display the preview messages in or as a delegate and datasource for a UITableView of your choice.
 
 If the UIViewController displaying the message should be separate from the UITableView displaying the previews, such as on the iPad or iPhone 6 Plus, you can send a NSNotification with the name "setContentViewController" and the object of the UIViewController to embed the content in. This will avoid the navigation to the message content when a cell is selected by the user and display the content in the specified UIViewController instead.
 */
@interface MCEInboxTableViewController : UITableViewController <UIViewControllerPreviewingDelegate>
@property BOOL ascending;
@end
