// -------------------------------------------------------
// ActivityCommentsDialogController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class Activity;

@interface ActivityCommentsDialogController : UITableViewController {
  Activity *activity;
}

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UITableViewCell *textCell;

- (id) initWithActivity: (Activity *) newActivity;

@end
