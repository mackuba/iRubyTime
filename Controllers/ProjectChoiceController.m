// -------------------------------------------------------
// ProjectChoiceController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "Project.h"
#import "ProjectChoiceController.h"
#import "Utils.h"

#define PROJECT_CELL_TYPE @"ActivityProjectCell"

@implementation ProjectChoiceController

OnDeallocRelease(activity, projects);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithActivity: (Activity *) newActivity projectList: (NSArray *) projectList {
  self = [super initWithStyle: UITableViewStyleGrouped];
  if (self) {
    activity = [newActivity retain];
    projects = [projectList retain];
    self.title = @"Choose project";
  }
  return self;
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
  return projects.count;
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  UITableViewCell *cell = [table cellWithStyle: UITableViewCellStyleDefault andIdentifier: PROJECT_CELL_TYPE];
  Project *project = (Project *) [projects objectAtIndex: path.row];
  cell.textLabel.text = project.name;
  cell.textLabel.font = [UIFont systemFontOfSize: 16];
  cell.textLabel.textColor = [UIColor darkGrayColor];

  if (project == activity.project) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }

  return cell;
}

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  if (activity.project != [projects objectAtIndex: path.row]) {
    NSInteger oldIndex = [projects indexOfObject: activity.project];
    if (oldIndex != NSNotFound) {
      UITableViewCell *oldCell = [table cellForRowAtIndexPath: RTIndex(0, oldIndex)];
      oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell *cell = [table cellForRowAtIndexPath: RTIndex(0, path.row)];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
      
    activity.project = [projects objectAtIndex: path.row];
  } 

  [table deselectRowAtIndexPath: path animated: YES];
  [self.navigationController popViewControllerAnimated: YES];
}

@end
