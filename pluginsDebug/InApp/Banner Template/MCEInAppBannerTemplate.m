/*
 * Copyright (C) 2024 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "MCEInAppBannerTemplate.h"

#if __has_feature(modules)
@import AcousticMobilePush;
#else
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

const CGFloat DEFAULT_ANIMATION_DURATION = 0.5;
const CGFloat DEFAULT_BANNER_DISPLAY_DURATION = 5;

@interface MCEInAppBannerTemplate ()
{
    MCEInAppMessage * _inAppMessage;
}
@property NSTimer * dismissTimer;
@property MCEInAppMessage * inAppMessage;
@property CGFloat animationDuration;
@property CGFloat bannerDisplayDuration;
@property UIColor * backgroundColor;
@property UIColor * foregroundColor;
@property UIImage * iconImage;
@property NSString * bannerText;
@property CGRect hiddenFrame;
@property CGRect visibleFrame;
@property CGFloat bannerHeight;
@end

@implementation MCEInAppBannerTemplate

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.bannerHeight = self.view.frame.size.height;
    
    self.close.image = [self.close.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceRotationNote:) name:@"UIApplicationDidChangeStatusBarFrameNotification" object:nil];
}

-(void)interfaceRotationNote:(NSNotification*)note
{
    [self interfaceRotation:@FALSE];
}

-(void)interfaceRotation:(NSNumber*)animate
{
    CGFloat deltaY = self.view.frame.origin.y - self.hiddenFrame.origin.y;
    CGFloat deltaX = self.view.frame.origin.x - self.hiddenFrame.origin.x;
    
    if([self isTopBanner])
    {
        CGRect hiddenFrame = self.hiddenFrame;
        
        [self configureTopBanner];
        
        deltaY -= hiddenFrame.size.height - self.hiddenFrame.size.height;
        
        if([animate boolValue]==FALSE)
        {
            // We don't know the final statusbar frame until after it's animated, so rerun this after it's animated
            [self performSelector:@selector(interfaceRotation:) withObject:@TRUE afterDelay:0.3f];
        }
    }
    else
    {
        [self configureBottomBanner];
    }
    
    CGRect frame = self.hiddenFrame;
    frame.origin.x += deltaX;
    frame.origin.y += deltaY;
    
    if([animate boolValue])
    {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(){
            
            self.view.frame = frame;
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        self.view.frame = frame;
    }
}

// Incoming call from MCEInAppRegistry to display a "default" InApp message
-(void)displayInAppMessage:(MCEInAppMessage*)message
{
    if(self.view.superview)
    {
        [self dismiss:self];
        [self performSelector:@selector(displayInAppMessage:) withObject:message afterDelay:0.1 + self.animationDuration];
        return;
    }
    
    [self setInAppMessage: message];
    [self configureBanner];
    if([self isTopBanner])
    {
        [self configureTopBanner];
    }
    else
    {
        [self configureBottomBanner];
    }
    
    if(message.content[@"mainImage"])
    {
        [NSThread detachNewThreadSelector:@selector(downloadImage:) toTarget:self withObject:message];
    }
    else
    {
        [self showBanner: nil];
    }
}

-(void)downloadImage:(MCEInboxMessage * )message
{
    UIImage * background_image = nil;
    NSURL * url = [NSURL URLWithString: message.content[@"mainImage"]];
    if(url)
    {
        NSData * background_image_data = [NSData dataWithContentsOfURL: url];
        if(background_image_data)
        {
            background_image = [UIImage imageWithData:background_image_data];
        }
    }
    
    [self performSelectorOnMainThread:@selector(showBanner:) withObject:background_image waitUntilDone:FALSE];
}

// Register with MCEInAppRegistry for displaying "default" InApp messages
+(void) registerTemplate
{
    [[MCEInAppTemplateRegistry sharedInstance] registerTemplate:@"default" handler:[[self alloc] initWithNibName: @"MCEInAppBannerTemplate" bundle: nil]];
}

- (CGFloat) determineIconHeight
{
    for (NSLayoutConstraint * constraint in self.icon.constraints)
    {
        if(constraint.firstAttribute == NSLayoutAttributeHeight)
        {
            return constraint.constant;
        }
    }
    
    return 0;
}

-(UIColor *)parseColor:(id)color defaultColor:(UIColor*)defaultColor
{
    if(color)
    {
        if([color isKindOfClass: [NSString class]])
        {
            return [UIColor colorWithHexString:color];
        }
        if([color isKindOfClass: [NSDictionary class]])
        {
            CGFloat red = [color[@"red"] floatValue];
            CGFloat green = [color[@"green"] floatValue];
            CGFloat blue = [color[@"blue"] floatValue];
            return [UIColor colorWithRed:red green:green blue:blue alpha:1];
        }
    }
    
    return defaultColor;
}

-(void)parseInAppMessage
{
    self.foregroundColor = [self parseColor:self.inAppMessage.content[@"foreground"] defaultColor: [UIColor whiteColor]];
    self.backgroundColor = [self parseColor:self.inAppMessage.content[@"color"] defaultColor: [UIColor colorWithRed:0.07 green:0.33 blue:0.74 alpha:1]];
    self.bannerText = self.inAppMessage.content[@"text"];
    self.iconImage = [[UIImage imageNamed: self.inAppMessage.content[@"icon"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.bannerDisplayDuration = [self parseBannerDuration];
    self.animationDuration = [self parseAnimationDuration];
}

-(CGFloat)parseBannerDuration
{
    NSString * duration = self.inAppMessage.content[@"duration"];
    if(duration)
    {
        return [duration floatValue];
    }
    return DEFAULT_BANNER_DISPLAY_DURATION;
}

-(CGFloat)parseAnimationDuration
{
    NSString * animation = self.inAppMessage.content[@"animationLength"];
    if(animation)
    {
        return [animation floatValue];
    }
    return DEFAULT_ANIMATION_DURATION;
}

-(void)setIconImage:(UIImage *)iconImage andWidth: (CGFloat)width
{
    for (NSLayoutConstraint * constraint in self.icon.constraints)
    {
        if(constraint.firstAttribute == NSLayoutAttributeWidth)
        {
            if(self.inAppMessage.content[@"icon"])
            {
                self.icon.image = self.iconImage;
                self.icon.tintColor = self.foregroundColor;
                constraint.constant=width;
            }
            else
            {
                constraint.constant=0;
                self.icon.image=nil;
            }
        }
    }
    
}

-(void)configureBanner
{
    self.view.backgroundColor = self.backgroundColor;
    self.label.text = self.bannerText;
    self.label.textColor = self.foregroundColor;
    self.close.tintColor = self.foregroundColor;
    [self setIconImage: self.iconImage andWidth: [self determineIconHeight]];
}

-(bool)isTopBanner
{
    return [self.inAppMessage.content[@"orientation"] isEqual: @"top"];
}

-(void)configureTopBanner
{
    self.bottomConstraint.active = true;
    self.topConstraint.active = false;
    
    UIWindow *window = [[MCESdk sharedInstance] getAppWindow];
    CGRect statusBarFrame = window.windowScene.statusBarManager.statusBarFrame;
    
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = window.frame.size.width;
    frame.size.height = self.bannerHeight + statusBarFrame.size.height;
    
    self.visibleFrame = frame;
    
    frame.size.width = window.frame.size.width;
    frame.origin.y = frame.size.height * -1;
    self.hiddenFrame = frame;
}

-(void)configureBottomBanner
{
    self.bottomConstraint.active = false;
    self.topConstraint.active = true;
    UIWindow *window = [[MCESdk sharedInstance] getAppWindow];
    
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    frame.size.width = window.frame.size.width;
    frame.size.height = self.bannerHeight;
    frame.size.height += window.safeAreaInsets.bottom;
    frame.origin.y = window.bounds.size.height - frame.size.height;
    
    self.visibleFrame = frame;
    
    frame.size.width = window.frame.size.width;
    frame.origin.y = window.bounds.size.height;
    self.hiddenFrame = frame;
}

-(void)showBanner: (UIImage *)background_image
{
    self.view.layer.contents = (__bridge id _Nullable)(background_image.CGImage);
    self.view.layer.contentsGravity = kCAGravityResizeAspect;

    UIWindow *window = [[MCESdk sharedInstance] getAppWindow];
    self.view.alpha = 0;
    self.view.frame = self.hiddenFrame;
    [window addSubview:self.view];

    // Preventing from recording views for canned inApp messages.
    if (self.inAppMessage.attribution != nil) {
        [[MCEEventService sharedInstance] recordViewForInAppMessage:self.inAppMessage attribution:self.inAppMessage.attribution mailingId:self.inAppMessage.mailingId];
    }
    
    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(){
        self.view.frame=self.visibleFrame;
        self.view.alpha = 1;
    } completion:^(BOOL complete){
        [self.dismissTimer invalidate];
        self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:self.bannerDisplayDuration target:self selector:@selector(dismiss:) userInfo:nil repeats:NO];
    }];
}

-(IBAction)dismiss:(id)sender
{
    [self.dismissTimer invalidate];
    self.dismissTimer = nil;
    
    if(self.view.superview)
    {
        [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(){
            self.view.frame = self.hiddenFrame;
            self.view.alpha = 0;
        } completion:^(BOOL complete){
            [self.view removeFromSuperview];
        }];
    }
}

-(IBAction)dismissRight:(id)sender
{
    CGRect frame = self.visibleFrame;
    frame.origin.x = frame.size.width;
    self.hiddenFrame = frame;
    [self dismiss:sender];
}

-(IBAction)dismissLeft:(id)sender
{
    CGRect frame = self.visibleFrame;
    frame.origin.x = -1 * frame.size.width;
    self.hiddenFrame = frame;
    [self dismiss:sender];
}

-(IBAction)tap:(id)sender
{
    NSDictionary * payload = @{@"mce": [NSMutableDictionary dictionary]};
    if(self.inAppMessage.attribution)
    {
        payload[@"mce"][@"attribution"] = self.inAppMessage.attribution;
    }
    if(self.inAppMessage.mailingId)
    {
        payload[@"mce"][@"mailingId"] = self.inAppMessage.mailingId;
    }
    [self dismiss:self];
    [MCEInAppManager.sharedInstance disable: self.inAppMessage];
    [MCEActionRegistry.sharedInstance performAction:self.inAppMessage.content[@"action"] forPayload:payload source:InAppSource attributes:nil userText:nil];
}

-(void)setInAppMessage:(MCEInAppMessage *)inAppMessage
{
    _inAppMessage = inAppMessage;
    [self parseInAppMessage];
}

-(MCEInAppMessage*)inAppMessage
{
    return _inAppMessage;
}


@end
