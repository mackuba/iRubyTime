// -------------------------------------------------------
// NewActivityDialogController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class Activity;
@class RubyTimeConnector;

@interface NewActivityDialogController : UIViewController {
  UIDatePicker *activityLengthPicker;
  UITableView *tableView;
  Activity *activity;
  RubyTimeConnector *connector;
}

@property (nonatomic, retain) IBOutlet UIDatePicker *activityLengthPicker;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (id) initWithConnector: (RubyTimeConnector *) connector;
- (IBAction) timeChanged;

@end
