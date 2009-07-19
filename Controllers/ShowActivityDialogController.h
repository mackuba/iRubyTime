// -------------------------------------------------------
// ShowActivityDialogController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class Activity;
@class RubyTimeConnector;
@class ActivityCommentsDialogController;
@class ActivityDateDialogController;
@class ActivityLengthDialogController;
@class ProjectChoiceController;

@interface ShowActivityDialogController : UITableViewController <UIActionSheetDelegate> {
  Activity *activity;
  Activity *originalActivity;
  RubyTimeConnector *connector;
  ProjectChoiceController *projectChoiceController;
  ActivityCommentsDialogController *activityCommentsDialogController;
  ActivityDateDialogController *activityDateDialogController;
  ActivityLengthDialogController *activityLengthDialogController;
  UIBarButtonItem *cancelButton;
}

- (id) initWithActivity: (Activity *) activity connector: (RubyTimeConnector *) connector;

@end
