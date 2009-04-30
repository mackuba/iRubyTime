// -------------------------------------------------------
// ActivityListConnector.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class LoginDialogController;
@class RubyTimeConnector;

@interface ActivityListController : UITableViewController {
  LoginDialogController *loginController;
  RubyTimeConnector *connector;
  NSMutableArray *activities;
}

- (void) loginSuccessful;

@end
