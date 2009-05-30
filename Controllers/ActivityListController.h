// -------------------------------------------------------
// ActivityListConnector.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class RubyTimeConnector;
@class ActivityCell;

@interface ActivityListController : UITableViewController {
  RubyTimeConnector *connector;
  ActivityCell *currentCell;
  UIActivityIndicatorView *spinner;
}

@property (nonatomic, assign) IBOutlet ActivityCell *currentCell;
@property (nonatomic, retain) IBOutlet RubyTimeConnector *connector;

- (void) loginSuccessful;

@end
