// -------------------------------------------------------
// RecordChoiceController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "RecordChoiceController.h"
#import "Utils.h"


@interface RecordChoiceController ()
- (NSString *) delegateGetterName;
@end


@implementation RecordChoiceController

PSReleaseOnDealloc(model, delegate);
@synthesize closeOnSelection;

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithModel: (Class) modelClass delegate: (id) aDelegate allowNil: (BOOL) allow {
  self = [super initWithStyle: UITableViewStyleGrouped];
  if (self) {
    model = [modelClass retain];
    delegate = [aDelegate retain];
    allowNil = allow;
    closeOnSelection = YES;
    self.title = PSFormat(@"Choose %@", [self delegateGetterName]);
  }
  return self;
}

// e.g. "Project"
- (NSString *) modelName {
  return NSStringFromClass(model);
}

// e.g. "project"
- (NSString *) delegateGetterName {
  return PSFormat(@"%@%@", [[[self modelName] substringToIndex: 1] lowercaseString], [[self modelName] substringFromIndex: 1]);
}

// e.g. "setProject:"
- (NSString *) delegateSetterName {
  return PSFormat(@"set%@:", [self modelName]);
}

// returns e.g. activity.project
- (PSModel *) delegateValue {
  return [delegate performSelector: NSSelectorFromString([self delegateGetterName])];
}

// calls e.g. activity.project = ...
- (void) setDelegateValue: (PSModel *) value {
  [delegate performSelector: NSSelectorFromString([self delegateSetterName]) withObject: value];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orientation {
  return RTiPad;
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSArray *) list {
  return [model list];
}

- (PSModel *) recordAtPath: (NSIndexPath *) path {
  if (allowNil && path.section == 0) {
    return nil;
  } else {
    return [[self list] objectAtIndex: path.row];
  }
}

- (NSIndexPath *) pathForRecord: (PSModel *) record {
  if (allowNil && !record) {
    return PSIndex(0, 0);
  } else {
    NSInteger row = [[self list] indexOfObject: [self delegateValue]];
    if (row == NSNotFound) {
      return nil;
    } else {
      return PSIndex(allowNil ? 1 : 0, row);
    }
  }
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView {
  return allowNil ? 2 : 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
  return (allowNil && section == 0) ? 1 : [[self list] count];
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  UITableViewCell *cell = [table psGenericCellWithStyle: UITableViewCellStyleDefault];
  id record = [self recordAtPath: path];
  cell.textLabel.text = (record) ? [record name] : PSFormat(@"All %@s", [self delegateGetterName]);

  if (record == [self delegateValue]) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }

  return cell;
}

- (UITableViewCell *) oldCellWithOldChoiceController: (RecordChoiceController *) oldController {
  NSIndexPath *oldIndexPath = [self pathForRecord: [self delegateValue]];
  if (oldIndexPath) {
    return [self.tableView cellForRowAtIndexPath: oldIndexPath];
  } else {
    oldIndexPath = [oldController pathForRecord: [self delegateValue]];
    if (oldIndexPath) {
      return [oldController.tableView cellForRowAtIndexPath: oldIndexPath];
    } else {
      return nil;
    }
  }
  return nil;
}

- (void) deselectOldCell {
  UITableViewCell *oldCell = [self oldCellWithOldChoiceController: nil];
  oldCell.accessoryType = UITableViewCellAccessoryNone;
}

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  if ([self delegateValue] != [self recordAtPath: path]) {
    [self deselectOldCell];
    UITableViewCell *cell = [table cellForRowAtIndexPath: path];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [self setDelegateValue: [self recordAtPath: path]];
  } 
  
  [table deselectRowAtIndexPath: path animated: YES];
  if (closeOnSelection) {
    [self.navigationController popViewControllerAnimated: YES];
  }
}

@end
