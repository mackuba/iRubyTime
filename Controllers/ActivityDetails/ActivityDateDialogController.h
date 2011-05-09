// -------------------------------------------------------
// ActivityDateDialogController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class Activity;

@interface ActivityDateDialogController : UIViewController {
  Activity *activity;
}

@property (nonatomic, retain) IBOutlet UIDatePicker *activityDatePicker;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (id) initWithActivity: (Activity *) activity;
- (IBAction) dateChanged;
- (IBAction) setToToday;
- (IBAction) setToYesterday;

@end
