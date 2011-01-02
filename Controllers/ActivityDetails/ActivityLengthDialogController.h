// -------------------------------------------------------
// ActivityLengthDialogController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class Activity;

@interface ActivityLengthDialogController : UIViewController {
  Activity *activity;
}

@property (nonatomic, retain) IBOutlet UIDatePicker *activityLengthPicker;

- (id) initWithActivity: (Activity *) activity;
- (IBAction) timeChanged;

@end
