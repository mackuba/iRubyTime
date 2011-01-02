// -------------------------------------------------------
// DateRangeController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@interface DateRangeController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  id delegate;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;

- (IBAction) dateChanged;
- (id) initWithDelegate: (id) aDelegate;

@end
