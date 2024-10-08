/*
 * Copyright (C) 2024 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "MCEInboxTableViewController.h"

#if __has_feature(modules)
@import AcousticMobilePush;
#else
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

@interface MCEInboxTableViewController () {
    NSData * _interfaceState;
}
@property CGPoint startingOffset;
@property NSMutableArray * inboxMessages;
@property NSMutableDictionary * richContents;
@property UIViewController * alternateDisplayViewController;
@property (nonatomic, strong) NSIndexPath *previewingIndexPath;
@property UIBarButtonItem * refreshButton;
@end

@interface NSObject (AssociatedObject)
@property (nonatomic, strong) id associatedObject;
@end

@implementation MCEInboxTableViewController

// The purpose of this method is to smoothly update the list of messages instead of just executing [self.tableView reloadData];
-(void)smartUpdateMessages:(NSMutableArray*)inboxMessages
{
    [self.tableView beginUpdates];
    NSSet * newInboxMessageSet = [NSSet setWithArray: inboxMessages];
    NSSet * inboxMessageSet = [NSSet setWithArray: self.inboxMessages];
    
    NSMutableSet * updatedInboxMessages = [newInboxMessageSet mutableCopy];
    [updatedInboxMessages intersectSet:inboxMessageSet];
    NSMutableArray * updatedIndexPaths = [NSMutableArray array];
    for(MCEInboxMessage * inboxMessage in updatedInboxMessages) {
        NSLog(@"Updated Message: %@", inboxMessage.sendDate);
        NSUInteger index = [self.inboxMessages indexOfObject: inboxMessage];
        if(index != NSNotFound) {
            MCEInboxMessage * oldInboxMessage = self.inboxMessages[index];
            if(oldInboxMessage && oldInboxMessage.isRead != inboxMessage.isRead) {
                NSLog(@"%d %d Changed Message: %@ at index %lu", oldInboxMessage.isRead, inboxMessage.isRead, inboxMessage.sendDate, (unsigned long)index);
                self.inboxMessages[index] = inboxMessage;
                [updatedIndexPaths addObject: [NSIndexPath indexPathForRow:index inSection:0]];
            }
        } else {
            NSLog(@"Couldn't find inbox message for update.");
        }
    }
    if([updatedIndexPaths count]) {
        [self.tableView reloadRowsAtIndexPaths: updatedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    NSMutableSet * deletedInboxMessages = [inboxMessageSet mutableCopy];
    [deletedInboxMessages minusSet: newInboxMessageSet];
    NSMutableArray * deletedIndexPaths = [NSMutableArray array];
    for(MCEInboxMessage * inboxMessage in deletedInboxMessages) {
        NSLog(@"Removed Message: %@", inboxMessage.sendDate);
        NSUInteger index = [self.inboxMessages indexOfObject: inboxMessage];
        if(index != NSNotFound) {
            NSLog(@"Remove row at index %lu", (unsigned long)index);
            [deletedIndexPaths addObject: [NSIndexPath indexPathForRow:index inSection:0]];
        } else {
            NSLog(@"Couldn't find inbox message for delete.");
        }
    }
    if([deletedIndexPaths count]) {
        for (NSIndexPath * indexPath in [deletedIndexPaths sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath * obj1, NSIndexPath * obj2) {
            return obj1.row > obj2.row ? NSOrderedAscending : NSOrderedDescending;
        }] ) {
            [self.inboxMessages removeObjectAtIndex: indexPath.row];
        }
        
        [self.tableView deleteRowsAtIndexPaths: deletedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    // Note, we can't use the combined update bits because the indexes added can be the same for multiple rows as it's going through
    [self.tableView endUpdates];
    
    NSMutableSet * addedInboxMessages = [newInboxMessageSet mutableCopy];
    [addedInboxMessages minusSet: inboxMessageSet];
    for(MCEInboxMessage * inboxMessage in addedInboxMessages) {
        NSLog(@"Added Message: %@", inboxMessage.sendDate);
        NSUInteger index = NSNotFound;
        for(MCEInboxMessage * oldInboxMessage in self.inboxMessages) {
            // Note, if you are ordering in ascending order, the operator below should be ">". If you are ordering in decending order, the operator below should be "<"
            if([oldInboxMessage.sendDate timeIntervalSince1970] < [inboxMessage.sendDate timeIntervalSince1970]) {
                index = [self.inboxMessages indexOfObject: oldInboxMessage];
                break;
            }
        }
        if(index == NSNotFound) {
            NSLog(@"Append message");
            [self.inboxMessages addObject: inboxMessage];
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.inboxMessages.count - 1 inSection:0];
            [self.tableView insertRowsAtIndexPaths: @[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            NSLog(@"Insert Message at index %lu", (unsigned long)index);
            [self.inboxMessages insertObject:inboxMessage atIndex:index];
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView insertRowsAtIndexPaths: @[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    
    if(self.startingOffset.y != 0) {
        self.tableView.contentOffset = self.startingOffset;
        self.startingOffset = CGPointZero;
    }
}

-(void)syncDatabase:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];

        NSMutableArray * inboxMessages = [[MCEInboxDatabase sharedInstance] inboxMessagesAscending:self.ascending];
        if(!inboxMessages)
        {
            NSLog(@"Could not sync database");
            return;
        }
        
        [self smartUpdateMessages:inboxMessages];
    });
}

-(void)setContentViewController: (NSNotification *) note {
    self.alternateDisplayViewController = note.object;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    // Notification that background server sync is complete
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDatabase:) name:MCESyncDatabase object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setContentViewController:) name:@"setContentViewController" object:nil];
    
    // Used by user to start a background server sync
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    self.inboxMessages=[NSMutableArray array];
    self.richContents = [NSMutableDictionary dictionary];
    
    // Initially, grab contents of database, then start a background server sync
    UIActivityIndicatorView * activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    [activity startAnimating];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:activity];
    
    NSMutableArray * inboxMessages = [[MCEInboxDatabase sharedInstance] inboxMessagesAscending: self.ascending];
    
    if(!inboxMessages)
    {
        NSLog(@"Could not fetch inbox messages");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self smartUpdateMessages:inboxMessages];
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        [[MCEInboxQueueManager sharedInstance] syncInbox];
    });
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MCEInboxMessage * inboxMessage = self.inboxMessages[indexPath.row];
        inboxMessage.isDeleted=TRUE;
        [self syncDatabase:nil];
    }
}

-(void)refresh:(id)sender
{
    [self.refreshControl beginRefreshing];
    [[MCEInboxQueueManager sharedInstance] syncInbox];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCEInboxMessage * inboxMessage = self.inboxMessages[indexPath.item];
    id<MCETemplate> template = [[MCETemplateRegistry sharedInstance] handlerForTemplate:inboxMessage.templateName];
    UITableViewCell* cell = [template cellForTableView: tableView inboxMessage:inboxMessage indexPath: indexPath];
    cell.associatedObject = indexPath;
    
    if(!cell)
    {
        NSLog(@"Couldn't get a blank cell for template %@, perhaps it wasn't registered?", template);
        cell = [tableView dequeueReusableCellWithIdentifier:@"oops"];
        if(!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"oops"];
        }
    }
    
    // Enable drag to create new window on iPadOS ≥ 13
    cell.userInteractionEnabled = true;
    [cell addInteraction: [[UIDragInteraction alloc] initWithDelegate: self]];

    return cell;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView  trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCEInboxMessage * inboxMessage = self.inboxMessages[indexPath.item];
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:nil handler:^(UIContextualAction * _Nonnull action, UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        // delete the item here
        NSLog(@"Delete message %@", inboxMessage.inboxMessageId);
        inboxMessage.isDeleted = TRUE;
        [self syncDatabase:nil];
        completionHandler(YES);
    }];
    deleteAction.image = [UIImage systemImageNamed:@"trash"];
    deleteAction.backgroundColor = [UIColor systemRedColor];
    
    UIContextualAction *unreadAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:nil handler:^(UIContextualAction * _Nonnull action, UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        // unread the item here
        inboxMessage.isRead = !inboxMessage.isRead;
        NSLog(@"Set message %@ to %@!", inboxMessage.inboxMessageId, inboxMessage.isRead ? @"Read" : @"Unread");
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        completionHandler(YES);
    }];
    unreadAction.title =  inboxMessage.isRead ? @"Mark as Unread" : @"Mark as Read";
    unreadAction.backgroundColor = [UIColor grayColor];
    
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction, unreadAction]];
    return configuration;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.tableView reloadData];
    }];
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    [super preferredContentSizeDidChangeForChildContentContainer:container];
}


- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    return [super sizeForChildContentContainer:container withParentContainerSize:parentSize];
}


- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    [super systemLayoutFittingSizeDidChangeForChildContentContainer:container];
}


- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}



-(UIViewController*)viewControllerForIndexPath:(NSIndexPath*)indexPath
{
    MCEInboxMessage * inboxMessage = self.inboxMessages[indexPath.row];
    return [self viewControllerForInboxMessage: inboxMessage];
}

-(MCEInboxMessage*) previousMessage: (MCEInboxMessage *) inboxMessage {
    NSUInteger index = [self.inboxMessages indexOfObject:inboxMessage];
    if(index > 0) {
        return self.inboxMessages[index-1];
    }
    return nil;
}

-(MCEInboxMessage*) nextMessage: (MCEInboxMessage *) inboxMessage {
    NSUInteger index = [self.inboxMessages indexOfObject:inboxMessage];
    if(self.inboxMessages.count > index + 1) {
        return self.inboxMessages[index+1];
    }
    return nil;
}

-(UIViewController*)viewControllerForInboxMessage: (MCEInboxMessage *) inboxMessage {
    NSString * template = inboxMessage.templateName;
    id <MCETemplate> templateHandler = [[MCETemplateRegistry sharedInstance] handlerForTemplate: template];
    id <MCETemplateDisplay> displayViewController = [templateHandler displayViewController];
    if(!displayViewController) {
        NSLog(@"%@ template requested but not registered", template);
        return nil;
    }
    
    if([templateHandler shouldDisplayInboxMessage:inboxMessage]) {
        NSLog(@"%@ template says should display inboxMessageId %@", template, inboxMessage.inboxMessageId);
    } else {
        NSLog(@"%@ template says should not display inboxMessageId %@", template, inboxMessage.inboxMessageId);
        return nil;
    }
    
    inboxMessage.isRead=TRUE;
    [[MCEEventService sharedInstance] recordViewForInboxMessage:inboxMessage attribution:inboxMessage.attribution mailingId:inboxMessage.mailingId];
    
    [displayViewController setInboxMessage: inboxMessage];
    [displayViewController setContent];
    
    UIViewController * vc = (UIViewController *)displayViewController;
    
    UIBarButtonItem * spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem * previousButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"chevron-up"] style:UIBarButtonItemStylePlain target:self action:@selector(openMessage:)];
    previousButton.accessibilityLabel = @"prev";
    MCEInboxMessage * previousInboxMessage = [self previousMessage: inboxMessage];
    if(previousInboxMessage) {
        previousButton.associatedObject = previousInboxMessage;
        previousButton.enabled=TRUE;
    } else {
        previousButton.enabled=FALSE;
    }
    
    UIBarButtonItem * nextButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"chevron-down"] style:UIBarButtonItemStylePlain target:self action:@selector(openMessage:)];
    nextButton.accessibilityLabel = @"next";
    
    MCEInboxMessage * nextInboxMessage = [self nextMessage: inboxMessage];
    if(nextInboxMessage) {
        nextButton.associatedObject = nextInboxMessage;
        nextButton.enabled=TRUE;
    } else {
        nextButton.enabled=FALSE;
    }
    
    UIBarButtonItem * deleteButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(delete:)];
    deleteButton.accessibilityLabel = @"trash";
    deleteButton.associatedObject = displayViewController;
    vc.navigationItem.rightBarButtonItems = @[deleteButton, spaceButton, nextButton, previousButton];
    
    return vc;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    UIViewController * vc = [self viewControllerForIndexPath:indexPath];
    
    if(self.alternateDisplayViewController)
    {
        [self.alternateDisplayViewController addChildViewController: vc];
        vc.view.frame = self.alternateDisplayViewController.view.frame;
        [self.alternateDisplayViewController.view addSubview: vc.view];
    }
    else
    {
        [self.navigationController pushViewController:vc animated:TRUE];
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(IBAction)delete:(UIBarButtonItem*)sender
{
    if(sender.associatedObject)
    {
        id <MCETemplateDisplay> templateDisplay = (id<MCETemplateDisplay>) sender.associatedObject;
        if(templateDisplay)
        {
            templateDisplay.inboxMessage.isDeleted=TRUE;
            [self.navigationController popViewControllerAnimated:TRUE];
            [self syncDatabase:nil];
        }
    }
}

-(IBAction)openMessage:(UIBarButtonItem*)sender
{
    if(sender.associatedObject)
    {
        MCEInboxMessage * inboxMessage = (MCEInboxMessage *) sender.associatedObject;
        if(inboxMessage)
        {
            [self.navigationController popViewControllerAnimated:TRUE];
            UIViewController * controller = [self viewControllerForInboxMessage: inboxMessage];
            [self.navigationController pushViewController: controller animated:true];
        }
    }
    
}

- (CGFloat)tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath
{
    MCEInboxMessage * inboxMessage = self.inboxMessages[indexPath.item];
    id<MCETemplate> template = [[MCETemplateRegistry sharedInstance] handlerForTemplate:inboxMessage.templateName];
    return [template tableView: tableView heightForRowAtIndexPath:indexPath inboxMessage:inboxMessage];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.inboxMessages count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *) tableView
{
    return 1;
}

// Generic State Restoration
-(void)setInterfaceState: (NSData*) interfaceState {
    _interfaceState = interfaceState;
}

// Generic State Restoration
-(NSData*)interfaceState {
    NSDictionary * userInfo = @{@"scroll": NSStringFromCGPoint(self.tableView.contentOffset)};
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
    
    self.startingOffset = CGPointFromString(interfaceState[@"scroll"]);
    
    _interfaceState = nil;
}

// State restoration iOS ≤12
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject: self.interfaceState forKey: @"interfaceState"];
}

// State restoration iOS ≤12
- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    self.interfaceState = [coder decodeObjectForKey:@"interfaceState"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MCEInboxQueueManager sharedInstance] syncInbox];
    });
    
    // State Restoration and Multiple Window Support iOS ≥13
    NSUserActivity * userActivity = self.view.window.windowScene.userActivity;
    if(userActivity && [userActivity respondsToSelector:@selector(initWithActivityType:)]) {
        self.userActivity = userActivity;
    } else {
        self.userActivity = [[NSUserActivity alloc] initWithActivityType:@"co.acoustic.mobilepush"];
        self.view.window.windowScene.userActivity = self.userActivity;
    }
    
    self.userActivity.title = NSStringFromClass(self.class);
    
    [self restoreInterfaceStateIfAvailable];
}

// State Restoration and Multiple Window Support iOS ≥13
-(void)updateUserActivityState:(NSUserActivity *)activity {
    [super updateUserActivityState:activity];
    [activity addUserInfoEntriesFromDictionary: @{@"interfaceState": self.interfaceState}];
}

// State Restoration and Multiple Window Support iOS ≥13
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    self.view.window.windowScene.userActivity = nil;
}

- (nonnull NSArray<UIDragItem *> *)dragInteraction:(nonnull UIDragInteraction *)interaction itemsForBeginningSession:(nonnull id<UIDragSession>)session { 
    return [[NSArray alloc] init];
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [super encodeWithCoder:coder];
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
    [super didUpdateFocusInContext:context withAnimationCoordinator:coordinator];
}

- (void)setNeedsFocusUpdate {
    [super setNeedsFocusUpdate];
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
    return [super shouldUpdateFocusInContext:context];
}

- (void)updateFocusIfNeeded {
    [super updateFocusIfNeeded];
}


@end
