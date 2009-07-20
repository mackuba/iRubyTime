// -------------------------------------------------------
// NewActivityDialogController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>
#import "ActivityDetailsController.h"

@interface NewActivityDialogController : ActivityDetailsController {
  UIDatePicker *activityLengthPicker;
}

@property (nonatomic, retain) IBOutlet UIDatePicker *activityLengthPicker;

- (id) initWithConnector: (RubyTimeConnector *) connector;
- (IBAction) timeChanged;

@end
