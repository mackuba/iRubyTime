// -------------------------------------------------------
// ShowActivityDialogController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class Activity;
@class RubyTimeConnector;

@interface ShowActivityDialogController : UITableViewController {
  Activity *activity;
  RubyTimeConnector *connector;
}

- (id) initWithActivity: (Activity *) activity connector: (RubyTimeConnector *) connector;
- (IBAction) deleteActivityClicked;

@end
