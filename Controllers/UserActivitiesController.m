// -------------------------------------------------------
// UserActivitiesController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "RubyTimeConnector.h"
#import "UserActivitiesController.h"
#import "Utils.h"

@implementation UserActivitiesController

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (RubyTimeConnector *) rtConnector {
  self = [super initWithConnector: rtConnector];
  if (self) {
    self.title = @"My activities";
    self.tabBarItem.image = [UIImage loadImageFromBundle: @"clock.png"];
  }
  return self;
}

- (BOOL) hasNewActivityButton {
  return YES;
}

- (void) fetchData {
  [super fetchData];
  [connector loadMyActivities];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (CGFloat) tableView: (UITableView *) table heightForRowAtIndexPath: (NSIndexPath *) path {
  return 69;
}

@end
