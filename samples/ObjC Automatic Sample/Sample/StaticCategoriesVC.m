/*
 * Copyright © 2011, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */
#import "StaticCategoriesVC.h"
#import "EditCell.h"
#import <objc/runtime.h>

#if __has_feature(modules)
@import AcousticMobilePush;
#else
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

@interface StaticCategoriesVC ()
@property UITextField * categoryId;
@property UITextField * button1;
@property UITextField * button2;
@end

@implementation StaticCategoriesVC


#pragma mark UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString * key = objc_getAssociatedObject(textField, @"key");
    [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:key];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.item<3)
    {
        EditCell * cell = [tableView dequeueReusableCellWithIdentifier:@"edit"];
        UITextField * detail = cell.editField;
        detail.delegate=self;

        NSString * key = nil;
        if(indexPath.item==0)
        {
            cell.textField.text=@"Category ID";
            key = @"categoryId";
            self.categoryId=detail;
        }
        else if(indexPath.item==1)
        {
            cell.textField.text=@"Button 1";
            key = @"button1";
            self.button1=detail;
        }
        else if(indexPath.item==2)
        {
            cell.textField.text=@"Button 2";
            key = @"button2";
            self.button2=detail;
        }
        
        objc_setAssociatedObject(detail, @"key", key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        cell.editField.text=[[NSUserDefaults standardUserDefaults] stringForKey:key];
        
        return cell;
    }
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
        return 3;
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0)
        return @"Example Category";
    return @"";
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section==0)
        return @"An example category with two buttons to demonstrate static categories.";
    
    return @"These action categories are implemented in the Sample App. You can get details about implementing categories at the Apple developer site";
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    
    if(indexPath.item==0)
        [self.categoryId becomeFirstResponder];
    else if(indexPath.item==1)
        [self.button1 becomeFirstResponder];
    else if(indexPath.item==2)
        [self.button2 becomeFirstResponder];
    else
    {
        [self.categoryId resignFirstResponder];
        [self.button1 resignFirstResponder];
        [self.button2 resignFirstResponder];
    }
}



@end
