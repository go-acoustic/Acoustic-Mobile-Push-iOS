/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "MCEInboxDefaultTemplateCell.h"

@interface MCEInboxDefaultTemplateCell () {
    MCEInboxMessage * _inboxMessage;
}
@property NSDateFormatter * formatter;

@end

@implementation MCEInboxDefaultTemplateCell

-(void)awakeFromNib {
    [super awakeFromNib];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setLocale:[NSLocale currentLocale]];
    self.formatter.timeStyle = NSDateFormatterNoStyle;
    self.formatter.dateStyle = NSDateFormatterShortStyle;
    [self prepareForReuse];
}

-(void)prepareForReuse {
    [super prepareForReuse];
    self.preview.text = @"";
    self.subject.text = @"";
    self.date.text = @"";
}

-(void)setStyleForExpiredMessage:(MCEInboxMessage *)inboxMessage {
    self.preview.alpha=0.5;
    self.subject.alpha=0.5;
    self.date.text = [@"Expired: " stringByAppendingString: [self.formatter stringFromDate: inboxMessage.expirationDate]];
    [self resizeDate];
}

-(void)resizeDate
{
    // Remove existing width constraint
    NSArray * constraints = [self.date constraints];
    for (NSLayoutConstraint * constraint in constraints) {
        if(constraint.firstAttribute == NSLayoutAttributeWidth) {
            [self.date removeConstraint: constraint];
        }
    }
    
    // Add new width constraint
    CGSize size = [self.date.text sizeWithAttributes: @{NSFontAttributeName: self.date.font }];
    [self.date addConstraint:[NSLayoutConstraint constraintWithItem:self.date attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:size.width+5]];
}

-(void)setStyleForNormalMessage:(MCEInboxMessage *)inboxMessage {
    self.preview.alpha=1;
    self.subject.alpha=1;
    self.date.text = [self.formatter stringFromDate: inboxMessage.sendDate];
    [self resizeDate];
}

-(MCEInboxMessage*)inboxMessage {
    return _inboxMessage;
}

-(void)setInboxMessage:(MCEInboxMessage *)inboxMessage {
    _inboxMessage = inboxMessage;
    
    if([inboxMessage isExpired]) {
        [self setStyleForExpiredMessage:inboxMessage];
    } else {
        [self setStyleForNormalMessage:inboxMessage];
    }
    
    NSDictionary * preview = inboxMessage.content[@"messagePreview"];
    
    if(inboxMessage.isRead) {
        self.subject.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    } else {
        self.subject.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    }
    
    self.subject.text = preview[@"subject"];
    self.preview.text = preview[@"previewContent"];
    [self updateTheme];
}

-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self updateTheme];
}

-(void)updateTheme {
    self.preview.textColor = [UIColor lightThemeColor:UIColor.grayColor darkThemeColor:UIColor.lightGrayColor];
    if([self.inboxMessage isExpired]) {
        self.date.textColor = [UIColor systemRedColor];
    } else {
        self.date.textColor = [UIColor lightThemeColor:[UIColor colorWithHexString:@"005CFF"] darkThemeColor:[UIColor colorWithHexString:@"7FADFF"]];
    }
}

@end
