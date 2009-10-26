// -------------------------------------------------------
// ProjectListController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Project.h"
#import "ProjectActivitiesController.h"
#import "ProjectListController.h"
#import "RubyTimeConnector.h"
#import "Utils.h"

#define PROJECT_CELL_TYPE @"ProjectCell"

@interface ProjectListController ()
- (ProjectActivitiesController *) controllerForProject: (Project *) project;
@end

@implementation ProjectListController

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (RubyTimeConnector *) rtConnector {
  self = [super initWithConnector: rtConnector andStyle: UITableViewStylePlain];
  if (self) {
    self.title = @"Projects";
    self.tabBarItem.image = [UIImage loadImageFromBundle: @"cabinet.png"];
    projectActivityListControllers = [[NSMutableDictionary alloc] init];
  }
  return self;
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  // TODO: show only projects that have any activities visible to you?
  return connector.projects.count;
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  UITableViewCell *cell = [table cellWithStyle: UITableViewCellStyleDefault andIdentifier: PROJECT_CELL_TYPE];
  Project *project = [connector.projects objectAtIndex: path.row];
  cell.textLabel.text = project.name;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return cell;
}

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  Project *project = [connector.projects objectAtIndex: path.row];
  ActivityListController *controller = [self controllerForProject: project];
  [self.navigationController pushViewController: controller animated: YES];
  [table deselectRowAtIndexPath: path animated: YES];
  [controller fetchDataIfNeeded];
}

- (ProjectActivitiesController *) controllerForProject: (Project *) project {
  ProjectActivitiesController *controller = [projectActivityListControllers objectForKey: project];
  if (!controller) {
    controller = [[ProjectActivitiesController alloc] initWithConnector: connector project: project];
    [projectActivityListControllers setObject: controller forKey: project];
    [controller release];
  }
  return controller;
}

@end
