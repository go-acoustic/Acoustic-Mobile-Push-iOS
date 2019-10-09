/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "MCEInboxDefaultTemplateDisplay.h"
#if __has_feature(modules)
@import AcousticMobilePush;
#else
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

@implementation MCEInboxDefaultTemplateDisplay

-(void)syncDatabase:(NSNotification*)notification {
    if(!self.inboxMessage) {
        return;
    }
    
    // May need to refresh if payload is out of sync.
    MCEInboxMessage* newInboxMessage = [[MCEInboxDatabase sharedInstance] inboxMessageWithInboxMessageId:self.inboxMessage.inboxMessageId];
    if(!newInboxMessage) {
        NSLog(@"Could not fetch inbox message %@", self.inboxMessage.inboxMessageId);
    }
    
    if([newInboxMessage isEqual: self.inboxMessage]) {
        return;
    }
    
    [self setContent];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDatabase:) name:MCESyncDatabase object:nil];
    }
    return self;
}

- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
    || (self.navigationController != nil && self.navigationController.presentingViewController.presentedViewController == self.navigationController)
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

-(IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:^{
    }];
}

-(void)setContent {
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(updateContent) withObject:nil waitUntilDone:false];
        return;
    }
    [self updateContent];
}

-(void)updateContent {
    [self updateTheme];
    if(self.date) {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        
        formatter.timeStyle = NSDateFormatterLongStyle;
        formatter.dateStyle = NSDateFormatterLongStyle;
        self.date.text = [formatter stringFromDate:self.inboxMessage.sendDate];
    }
    
    if(self.subject) {
        NSDictionary * preview = self.inboxMessage.content[@"messagePreview"];
        self.subject.text=preview[@"subject"];
    }
    
    if(self.webView) {
        NSDictionary * messageDetails = self.inboxMessage.content[@"messageDetails"];
        if(messageDetails && [messageDetails respondsToSelector:@selector(isEqualToDictionary:)] ) {
            NSString * html = messageDetails[@"richContent"];
            if(html && [html respondsToSelector:@selector(isEqualToString:)]) {
                // If the html is just a fragment, add viewport to improve rendering.
                if(![[html lowercaseString] containsString:@"<html"]) {
                    html = [NSString stringWithFormat: @"<!DOCTYPE html><html><head><meta name='viewport' content='width=device-width'></head><body>%@</body></html>", html];
                }

                [self.webView loadHTMLString:html baseURL:nil];
            } else {
                [self.webView loadHTMLString:@"" baseURL:nil];
                NSLog(@"No HTML content found!");
            }
        }
        self.webView.hidden=FALSE;
    }
    
    if(self.boxView) {
        self.boxView.hidden=FALSE;
    }
    
    if(self.progressView) {
        self.progressView.hidden=FALSE;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateContent];
    
    self.boxView.layer.borderWidth=1;
    if (@available(iOS 13.0, *)) {
        self.boxView.layer.borderColor = UIColor.separatorColor.CGColor;
    } else {
        self.boxView.layer.borderColor = [UIColor colorWithHexString:@"e0e0e0"].CGColor;
    }
    
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    CGFloat statusBarHeight = MIN(statusBarSize.width, statusBarSize.height);
    CGFloat toolbarHeight = self.toolbar.frame.size.height;
    
    // Adjust spacing between toolbar and top when translucent toolbar or when popup
    if([self isModal])
    {
        self.topConstraint.constant = 0;
        self.toolbarHeightConstraint.constant = toolbarHeight + statusBarHeight;
        
        UIWindow * window = UIApplication.sharedApplication.keyWindow;
        if (@available(iOS 11.0, *)) {
            if(window.safeAreaInsets.top > statusBarHeight) {
                self.toolbarHeightConstraint.constant = toolbarHeight + window.safeAreaInsets.top;
            } else {
                self.toolbarHeightConstraint.constant = toolbarHeight + statusBarHeight;
            }
        } else {
            self.toolbarHeightConstraint.constant = toolbarHeight + statusBarHeight;
        }
    }
    else if(self.navigationController.navigationBar.translucent)
    {
        self.topConstraint.constant = statusBarHeight + toolbarHeight;
        self.toolbarHeightConstraint.constant = 0;
    }
    else
    {
        self.topConstraint = 0;
        self.toolbarHeightConstraint.constant = 0;
    }
    
    if(self.inboxMessage)
    {
        [self setContent];
        self.inboxMessage.isRead = TRUE;
    }
}

-(void)setLoading {
    self.progressView.progress = 0;
    self.progressView.hidden=true;
    self.boxView.hidden=TRUE;
    self.webView.hidden=TRUE;
}

-(void)presentLoadingError: (NSError*)error {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Failed to load web content" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction: [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:true completion:nil];
    }]];
    [self presentViewController:alert animated:true completion: nil];
}

// We have to create the WKWebView in code to support iOS 9
-(void)loadView {
    [super loadView];
    
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc] init];
    configuration.ignoresViewportScaleLimits = true;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    self.webView.translatesAutoresizingMaskIntoConstraints = false;
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addSubview: self.webView];
    
    NSDictionary * views = @{@"webView": self.webView, @"toolbar": self.toolbar, @"progressView": self.progressView};
    NSMutableArray * constraints = [NSMutableArray array];
    [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webView]-0-|" options:0 metrics:nil views:views]];

    [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[progressView]-0-[webView]-0-|" options:0 metrics:nil views:views]];

    [NSLayoutConstraint activateConstraints: constraints];
}

#pragma mark WKNavigationDelegate methods

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.progressView.progress = 0;
    [self.progressView setHidden:false];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.progressView setHidden:true];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView setHidden:true];
    [self presentLoadingError:error];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView setHidden:true];
    [self presentLoadingError:error];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([keyPath isEqual: @"estimatedProgress"]) {
        self.progressView.progress = self.webView.estimatedProgress;
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL * url = navigationAction.request.URL;
    if([url.scheme isEqual:@"about"]) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

    NSDictionary * actions = self.inboxMessage.content[@"actions"];
    if(actions && [actions respondsToSelector:@selector(isEqualToDictionary:)]) {
        if([url.scheme isEqual:@"actionid"]) {
            NSDictionary * action = actions[url.resourceSpecifier];
            if(action) {
                NSDictionary * eventPayload = @{@"mce": [@{} mutableCopy]};
                if(self.inboxMessage.attribution)
                    eventPayload[@"mce"][@"attribution"] = self.inboxMessage.attribution;
                if(self.inboxMessage.mailingId)
                    eventPayload[@"mce"][@"mailingId"] = self.inboxMessage.mailingId;
                
                [MCEActionRegistry.sharedInstance performAction:action forPayload:eventPayload source:InboxSource attributes:@{} userText:nil];
            } else {
                NSLog(@"Can't navigate! Could not find an action for action handler %@", url.resourceSpecifier);
            }
        } else {
            NSLog(@"Can't navigate! Link clicked in Inbox content, but isn't an actionid link! %@", url.scheme);
        }
    } else {
        NSLog(@"Can't navigate! Current inbox message doesn't have action payload!");
    }
    decisionHandler(WKNavigationActionPolicyCancel);
    return;
}

-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self updateTheme];
}

-(void)updateTheme {
    if([self.inboxMessage isExpired]) {
        self.date.textColor = [UIColor systemRedColor];
    } else {
        self.date.textColor = [UIColor lightThemeColor:[UIColor colorWithHexString:@"005CFF"] darkThemeColor:[UIColor colorWithHexString:@"7FADFF"]];
    }
    if (@available(iOS 13.0, *)) {
        self.boxView.backgroundColor = [UIColor systemBackgroundColor];
    }
}

@end
