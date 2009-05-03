// -------------------------------------------------------
// ActivityListConnector.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class LoginDialogController;
@class RubyTimeConnector;
@class ActivityCell;

@interface ActivityListController : UITableViewController {
  LoginDialogController *loginController;
  RubyTimeConnector *connector;
  NSMutableArray *activities;
  ActivityCell *currentCell;
  UIActivityIndicatorView *spinner;
}

@property (nonatomic, assign) IBOutlet ActivityCell *currentCell;

- (void) loginSuccessful;

@end
