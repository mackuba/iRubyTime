//
//  SubActivityTypeChoiceController.m
//  RubyTime
//
//  Created by Ania on 12/17/10.
//  Copyright 2010 (c). All rights reserved.
//

#import "SubActivityTypeChoiceController.h"
#import "Activity.h"
#import "ActivityType.h"
#import "ActivityTypeChoiceController.h"

@implementation SubActivityTypeChoiceController

PSReleaseOnDealloc(parent, activityType);

- (id) initWithActivity: (Activity *) newActivity activityType: (ActivityType *) newActivityType parent: (ActivityTypeChoiceController *) newParent {
  self = [super initWithModel: [ActivityType class] delegate: newActivity allowNil: NO];
  if (self) {
    activityType = [newActivityType retain];
    parent = newParent;
    closeOnSelection = NO;
  }
  return self;
}

- (NSArray *) list {
  return [activityType availableSubactivityTypes];
}

- (void) deselectOldCell {
  UITableViewCell *oldCell = [self oldCellWithOldChoiceController: (RecordChoiceController *)parent];
  oldCell.accessoryType = UITableViewCellAccessoryNone;
}

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  [super tableView: table didSelectRowAtIndexPath: path];
  [self.navigationController popToViewController: [parent parent] animated: YES];
}

@end
