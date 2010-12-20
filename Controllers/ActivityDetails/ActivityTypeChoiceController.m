//
//  ActivityTypeChoiceController.m
//  RubyTime
//
//  Created by Anna Lesniak on 12/3/10.
//  Copyright 2010 (c). All rights reserved.
//

#import "ActivityType.h"
#import "Activity.h"
#import "Project.h"
#import "ActivityTypeChoiceController.h"
#import "SubActivityTypeChoiceController.h"


@implementation ActivityTypeChoiceController

@synthesize parent;

- (id) initWithActivity: (Activity *) activity parent: (UIViewController *) newParent {
  self = [super initWithModel: [ActivityType class] delegate: activity allowNil: NO];
  if (self) {
    parent = newParent;
  }
  return self;
}

- (void) viewWillAppear: (BOOL) animated {
  [self.tableView reloadData];
}

- (NSArray *) list {
  return [[delegate project] availableActivityTypes];
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  UITableViewCell *cell = [super tableView: table cellForRowAtIndexPath: path];
  ActivityType *activityType = (ActivityType *) [self recordAtPath: path];
  if ([activityType hasAvailableSubactivityTypes]) {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  return cell;
}

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  ActivityType *activityType = [[self list] objectAtIndex: path.row];
  if ([activityType hasAvailableSubactivityTypes]) {
    SubActivityTypeChoiceController *controller = [[SubActivityTypeChoiceController alloc] initWithActivity: delegate
                                                                 activityType: activityType
                                                                       parent: self];
    [self.navigationController pushViewController: controller animated: YES];
    [controller release];
  } else {
    [super tableView: table didSelectRowAtIndexPath: path];
  }
}

- (void) viewDidLoad {
  [super viewDidLoad];
  [self psSetBackButtonTitle: @"ActivityType"];
}

@end
