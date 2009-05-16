// -------------------------------------------------------
// NewActivityDialogController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class Activity;
@class ActivityCommentsDialogController;
@class ActivityDateDialogController;
@class ProjectChoiceController;
@class RubyTimeConnector;

@interface NewActivityDialogController : UIViewController {
  UIDatePicker *activityLengthPicker;
  UITableView *tableView;
  Activity *activity;
  RubyTimeConnector *connector;
  ProjectChoiceController *projectChoiceController;
  ActivityCommentsDialogController *activityCommentsDialogController;
  ActivityDateDialogController *activityDateDialogController;
  UIBarButtonItem *loadingButton;
  UIBarButtonItem *saveButton;
  UIActivityIndicatorView *spinner;
}

@property (nonatomic, retain) IBOutlet UIDatePicker *activityLengthPicker;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (id) initWithConnector: (RubyTimeConnector *) connector;
- (IBAction) timeChanged;

@end