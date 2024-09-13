/*
 * Copyright © 2017, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#if __has_feature(modules)
@import AcousticMobilePush;
#else
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

#import "ExampleViewController.h"

@implementation ExampleViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil payload:(NSDictionary*)payload
{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        NSError * error = nil;
        NSData * data = [NSJSONSerialization dataWithJSONObject: payload options:NSJSONWritingPrettyPrinted error:&error];
        if(error)
        {
            NSLog(@"Couldn't encode json");
        }
        else
        {
            self.payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    return self;
}

-(IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:^{ }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.payload)
    {
        self.payloadLabel.text = self.payload;
    }
}

@end

