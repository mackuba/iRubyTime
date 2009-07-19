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
  UITableViewCell *commentsCell;
  UILabel *commentsLabel;
}

@property (nonatomic, retain) IBOutlet UIDatePicker *activityLengthPicker;
@property (nonatomic, retain) IBOutlet UITableViewCell *commentsCell;
@property (nonatomic, retain) IBOutlet UILabel *commentsLabel;

- (id) initWithConnector: (RubyTimeConnector *) connector;
- (IBAction) timeChanged;

@end
