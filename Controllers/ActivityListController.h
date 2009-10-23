// -------------------------------------------------------
// ActivityListController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class ActivityCell;
@class LoadingView;
@class RubyTimeConnector;

@interface ActivityListController : UITableViewController {
  ActivityCell *currentCell;
  LoadingView *loadingView;
  RubyTimeConnector *connector;
}

@property (nonatomic, assign) IBOutlet ActivityCell *currentCell;
@property (nonatomic, retain) IBOutlet RubyTimeConnector *connector;

@end
