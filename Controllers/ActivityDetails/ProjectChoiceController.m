// -------------------------------------------------------
// ProjectChoiceController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "Project.h"
#import "ProjectChoiceController.h"
#import "ActivityDetailsController.h"

@implementation ProjectChoiceController

- (id) initWithActivity: (Activity *) activity {
  return [super initWithModel: [Project class] delegate: activity allowNil: NO];
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  UITableViewCell *cell = [super tableView: table cellForRowAtIndexPath: path];
  Project *project = (Project *) [self recordAtPath: path];
  if (project.hasActivities) {
    cell.textLabel.font = [UIFont boldSystemFontOfSize: 16.0];
  } else {
    cell.textLabel.font = [UIFont systemFontOfSize: 16.0];
  }
  return cell;
}

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  [delegate setActivityType: nil];
  [super tableView: table didSelectRowAtIndexPath: path];
}

@end
