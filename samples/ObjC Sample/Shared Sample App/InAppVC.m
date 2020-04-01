/*
 * Copyright © 2014, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "InAppVC.h"

#define BOTTOM_BANNER_ITEM 0
#define TOP_BANNER_ITEM 1
#define IMAGE_ITEM 2
#define VIDEO_ITEM 3
#define NEXT_ITEM 4

#define EXECUTE_SECTION 0
#define CANNED_SECTION 1

@interface InAppVC ()

@end

@implementation InAppVC

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0)
        return 50;
    return 34;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section)
    {
        case EXECUTE_SECTION:
            return @"Execute InApp";
        case CANNED_SECTION:
            return @"Add Canned InApp";
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    switch (indexPath.item) {
        case TOP_BANNER_ITEM:
            cell.textLabel.text = @"Top Banner Template";
            break;
        case BOTTOM_BANNER_ITEM:
            cell.textLabel.text = @"Bottom Banner Template";
            break;
        case IMAGE_ITEM:
            cell.textLabel.text = @"Image Template";
            break;
        case VIDEO_ITEM:
            cell.textLabel.text = @"Video Template";
            break;
        case NEXT_ITEM:
            cell.textLabel.text = @"Next Queued Template";
            break;
    }

    return cell;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [MCEInboxQueueManager.sharedInstance syncInbox];
    [[MCEActionRegistry sharedInstance] registerTarget:self withSelector:@selector(displayVideo:) forAction:@"showVideo"];
    [[MCEActionRegistry sharedInstance] registerTarget:self withSelector:@selector(displayTopBanner:) forAction:@"showTopBanner"];
    [[MCEActionRegistry sharedInstance] registerTarget:self withSelector:@selector(displayBottomBanner:) forAction:@"showBottomBanner"];
    [[MCEActionRegistry sharedInstance] registerTarget:self withSelector:@selector(displayImage:) forAction:@"showImage"];
}

-(void)displayBottomBanner:(NSDictionary*)userInfo
{
    [[MCEInAppManager sharedInstance] executeRule:@[@"bottomBanner"]];
}

-(void)displayTopBanner:(NSDictionary*)userInfo
{
    [[MCEInAppManager sharedInstance] executeRule:@[@"topBanner"]];
}

-(void)displayNext:(NSDictionary*)userInfo
{
    [[MCEInAppManager sharedInstance] executeRule:@[@"all"]];
}

-(void)displayImage:(NSDictionary*)userInfo
{
    [[MCEInAppManager sharedInstance] executeRule:@[@"image"]];
}

-(void)displayVideo:(NSDictionary*)userInfo
{
    [[MCEInAppManager sharedInstance] executeRule:@[@"video"]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case EXECUTE_SECTION:
            return 5;
        case CANNED_SECTION:
            return 4;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    switch (indexPath.section) {
        case EXECUTE_SECTION:
            switch (indexPath.item) {
                case TOP_BANNER_ITEM:
                    [self displayTopBanner: nil];
                    break;
                case BOTTOM_BANNER_ITEM:
                    [self displayBottomBanner: nil];
                    break;
                case IMAGE_ITEM:
                    [self displayImage: nil];
                    break;
                case VIDEO_ITEM:
                    [self displayVideo: nil];
                    break;
                case NEXT_ITEM:
                    [self displayNext: nil];
                    break;
            }
            
            break;
            
        case CANNED_SECTION:
        {
            NSDictionary * userInfo;
            
            switch (indexPath.item) {
                case TOP_BANNER_ITEM:
                {
                    userInfo = @{@"inApp": @{
                                         @"rules": @[@"topBanner", @"all"],
                                         @"maxViews": @5,
                                         @"template": @"default",
                                         @"content": @{
                                                 @"orientation":@"top",
                                                 @"action": @{@"type":@"url", @"value": @"http://acoustic.co"},
                                                 @"text":@"Canned Banner Template Text",
                                                 @"icon": @"note",
                                                 @"color": @"0077FF"
                                                 },
                                         @"triggerDate": [MCEApiUtil dateToIso8601Format: [NSDate distantPast] ],
                                         @"expirationDate": [MCEApiUtil dateToIso8601Format: [NSDate distantFuture] ],
                                         },
                                 };
                    break;
                }
                case BOTTOM_BANNER_ITEM:
                {
                    userInfo = @{@"inApp": @{
                                         @"rules": @[@"bottomBanner", @"all"],
                                         @"maxViews": @5,
                                         @"template": @"default",
                                         @"content": @{
                                                 @"action": @{@"type":@"url", @"value": @"http://acoustic.co"},
                                                 @"text":@"Canned Banner Template Text",
                                                 @"icon": @"note",
                                                 @"color": @"0077FF"
                                                 },
                                         @"triggerDate": [MCEApiUtil dateToIso8601Format: [NSDate distantPast] ],
                                         @"expirationDate": [MCEApiUtil dateToIso8601Format: [NSDate distantFuture] ],
                                         },
                                 };
                    break;
                }
                case IMAGE_ITEM:
                {
                    userInfo = @{@"inApp": @{
                                         @"rules": @[@"image", @"all"],
                                         @"maxViews": @5,
                                         @"template": @"image",
                                         @"content": @{
                                                 @"action": @{@"type":@"url", @"value": @"http://acoustic.co"},
                                                 @"title":@"Canned Image Template Title",
                                                 @"text":@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque rhoncus, eros sed imperdiet finibus, purus nibh placerat leo, non fringilla massa tortor in tellus. Donec aliquet pharetra dui ac tincidunt. Ut eu mi at ligula varius suscipit. Vivamus quis quam nec urna sollicitudin egestas eu at elit. Nulla interdum non ligula in lobortis. Praesent lobortis justo at cursus molestie. Aliquam lectus velit, elementum non laoreet vitae, blandit tempus metus. Nam ultricies arcu vel lorem cursus aliquam. Nunc eget tincidunt ligula, quis suscipit libero. Integer velit nisi, lobortis at malesuada at, dictum vel nisi. Ut vulputate nunc mauris, nec porta nisi dignissim ac. Sed ut ante sapien. Quisque tempus felis id maximus congue. Aliquam quam eros, congue at augue et, varius scelerisque leo. Vivamus sed hendrerit erat. Mauris quis lacus sapien. Nullam elit quam, porttitor non nisl et, posuere volutpat enim. Praesent euismod at lorem et vulputate. Maecenas fermentum odio non arcu iaculis egestas. Praesent et augue quis neque elementum tincidunt. ",
                                                 @"image": @"https://picsum.photos/800/800"
                                                 }
                                         },
                                 @"triggerDate": [MCEApiUtil dateToIso8601Format: [NSDate distantPast] ],
                                 @"expirationDate": [MCEApiUtil dateToIso8601Format: [NSDate distantFuture] ],
                                 };
                    break;
                }
                case VIDEO_ITEM:
                {
                    userInfo = @{@"inApp": @{
                                         @"rules": @[@"video", @"all"],
                                         @"maxViews": @5,
                                         @"template": @"video",
                                         @"content": @{
                                                 @"action": @{@"type":@"url", @"value": @"http://acoustic.co"},
                                                 @"title":@"Canned Video Template Title",
                                                 @"text":@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque rhoncus, eros sed imperdiet finibus, purus nibh placerat leo, non fringilla massa tortor in tellus. Donec aliquet pharetra dui ac tincidunt. Ut eu mi at ligula varius suscipit. Vivamus quis quam nec urna sollicitudin egestas eu at elit. Nulla interdum non ligula in lobortis. Praesent lobortis justo at cursus molestie. Aliquam lectus velit, elementum non laoreet vitae, blandit tempus metus. Nam ultricies arcu vel lorem cursus aliquam. Nunc eget tincidunt ligula, quis suscipit libero. Integer velit nisi, lobortis at malesuada at, dictum vel nisi. Ut vulputate nunc mauris, nec porta nisi dignissim ac. Sed ut ante sapien. Quisque tempus felis id maximus congue. Aliquam quam eros, congue at augue et, varius scelerisque leo. Vivamus sed hendrerit erat. Mauris quis lacus sapien. Nullam elit quam, porttitor non nisl et, posuere volutpat enim. Praesent euismod at lorem et vulputate. Maecenas fermentum odio non arcu iaculis egestas. Praesent et augue quis neque elementum tincidunt. ",
                                                 @"video":@"http://techslides.com/demos/sample-videos/small.mp4"
                                                 }
                                         },
                                 @"triggerDate": [MCEApiUtil dateToIso8601Format: [NSDate distantPast] ],
                                 @"expirationDate": [MCEApiUtil dateToIso8601Format: [NSDate distantFuture] ],
                                 };
                    break;
                }
            }
            
            [MCEInAppManager.sharedInstance processPayload: userInfo];
            
            break;
        }
    }
    
}

@end
