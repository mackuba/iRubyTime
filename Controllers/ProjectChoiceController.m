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

#define PROJECT_CELL_TYPE @"ProjectCell"

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
  UITableViewCell *cell = [table dequeueReusableCellWithIdentifier: PROJECT_CELL_TYPE];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithFrame: CGRectZero reuseIdentifier: PROJECT_CELL_TYPE] autorelease];
  }
  Project *project = (Project *) [projects objectAtIndex: path.row];
  cell.text = project.name;
  return cell;
}

- (UITableViewCellAccessoryType) tableView: (UITableView *) table
          accessoryTypeForRowWithIndexPath: (NSIndexPath *) path {
  NSLog(@"%@ %d", activity.project, activity.project.projectId);
  if (activity.project == [projects objectAtIndex: path.row]) {
    return UITableViewCellAccessoryCheckmark;
  } else {
    return UITableViewCellAccessoryNone;
  }
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
