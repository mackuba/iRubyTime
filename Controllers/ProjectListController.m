// -------------------------------------------------------
// ProjectListController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "Project.h"
#import "ProjectActivitiesController.h"
#import "ProjectListController.h"
#import "ServerConnector.h"
#import "Utils.h"


@interface ProjectListController ()
- (ProjectActivitiesController *) subcontrollerForProject: (Project *) project;
@end


@implementation ProjectListController

PSReleaseOnDealloc(subcontrollers, projectList);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (ServerConnector *) rtConnector {
  self = [super initWithConnector: rtConnector andStyle: UITableViewStylePlain];
  if (self) {
    self.title = @"Projects";
    self.tabBarItem.image = [UIImage loadImageFromBundle: @"cabinet.png"];
    subcontrollers = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void) viewWillAppear: (BOOL) animated {
  [projectList release];
  projectList = ([connector.account userType] == Employee) ? [Project allWithActivities] : [Project list];
  [projectList retain];
  [tableView reloadData];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  return projectList.count;
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  UITableViewCell *cell = [table psGenericCellWithStyle: UITableViewCellStyleDefault];
  Project *project = [projectList objectAtIndex: path.row];
  cell.textLabel.text = project.name;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return cell;
}

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  Project *project = [projectList objectAtIndex: path.row];
  ActivityListController *controller = [self subcontrollerForProject: project];
  [self.navigationController pushViewController: controller animated: YES];
  [table deselectRowAtIndexPath: path animated: YES];
}

- (ProjectActivitiesController *) subcontrollerForProject: (Project *) project {
  ProjectActivitiesController *controller = [subcontrollers objectForKey: project];
  if (!controller) {
    controller = [[ProjectActivitiesController alloc] initWithConnector: connector project: project];
    [subcontrollers setObject: controller forKey: project];
    [controller release];
  }
  return controller;
}

// -------------------------------------------------------------------------------------------
#pragma mark Cleanup

- (void) didReceiveMemoryWarning {
  [subcontrollers removeAllObjects];
}

@end
