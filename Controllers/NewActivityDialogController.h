// -------------------------------------------------------
// NewActivityDialogController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>
#import "ActivityDetailsController.h"

#define ActivityDialogCancelledNotification @"ActivityDialogCancelledNotification"

@interface NewActivityDialogController : ActivityDetailsController {
  UIDatePicker *activityLengthPicker;
  NSArray *activityList;
}

@property (nonatomic, retain) IBOutlet UIDatePicker *activityLengthPicker;

- (id) initWithConnector: (RubyTimeConnector *) rtConnector andActivityList: (NSArray *) activities;
- (IBAction) timeChanged;

@end
