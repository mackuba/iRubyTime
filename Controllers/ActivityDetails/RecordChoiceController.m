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
  return [[self modelName] lowercaseString];
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

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (PSModel *) recordAtPath: (NSIndexPath *) path {
  if (allowNil && path.section == 0) {
    return nil;
  } else {
    return [[model list] objectAtIndex: path.row];
  }
}

- (NSIndexPath *) pathForRecord: (PSModel *) record {
  if (allowNil && !record) {
    return PSIndex(0, 0);
  } else {
    NSInteger row = [[model list] indexOfObject: [self delegateValue]];
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
  return (allowNil && section == 0) ? 1 : [model count];
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

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  if ([self delegateValue] != [self recordAtPath: path]) {
    NSIndexPath *oldIndexPath = [self pathForRecord: [self delegateValue]];
    if (oldIndexPath) {
      UITableViewCell *oldCell = [table cellForRowAtIndexPath: oldIndexPath];
      oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
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
