// -------------------------------------------------------
// ActivityCell.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class Activity;

@interface ActivityCell : UITableViewCell {}

@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *hoursLabel;
@property (nonatomic, retain) IBOutlet UILabel *commentsLabel;
@property (nonatomic, retain) IBOutlet UILabel *projectLabel;
@property (nonatomic, retain) IBOutlet UILabel *activityTypeLabel;
@property (nonatomic, retain) IBOutlet UILabel *userLabel;

- (void) displayActivity: (Activity *) activity;

@end
