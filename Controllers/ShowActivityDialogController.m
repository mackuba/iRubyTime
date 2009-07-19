// -------------------------------------------------------
// ShowActivityDialogController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "ShowActivityDialogController.h"

#define DELETE_ACTIVITY_CELL_TYPE @"DeleteActivityCell"

@interface ShowActivityDialogController ()
- (void) deleteActivityClicked;
- (void) clearHelperControllers;
@end;


@implementation ShowActivityDialogController

OnDeallocRelease(originalActivity, editButton);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithActivity: (Activity *) anActivity connector: (RubyTimeConnector *) rtConnector {
  self = [super initWithConnector: rtConnector nibName: @"ShowActivityDialog"];
  if (self) {
    activity = [anActivity copy];
    originalActivity = [anActivity retain];
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  tableView.allowsSelectionDuringEditing = YES;
  Observe(connector, @"activityEdited", activityEdited);
  Observe(connector, @"activityDeleted", activityDeleted);
}

- (void) setupToolbar {
  [super setupToolbar];
  editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemEdit
                                                             target: self
                                                             action: @selector(editClicked)];
  self.navigationItem.rightBarButtonItem = editButton;
  self.navigationItem.title = @"Activity details";
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) deleteActivityClicked {
  UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle: @"Do you really want to delete this activity?"
                                                     delegate: self
                                            cancelButtonTitle: @"Cancel"
                                       destructiveButtonTitle: @"Delete"
                                            otherButtonTitles: nil];
  [sheet showInView: self.view];
  [sheet release];
}

- (void) actionSheet: (UIActionSheet *) sheet clickedButtonAtIndex: (NSInteger) index {
  if (index == 0) {
    self.navigationItem.rightBarButtonItem = loadingButton;
    [spinner startAnimating];
    [connector deleteActivity: activity];
  }
  [tableView deselectRowAtIndexPath: RTIndex(1, 0) animated: YES];
}

- (void) cancelClicked {
  [activity release];
  activity = [originalActivity copy];
  [tableView reloadData];
  [self setEditing: NO animated: YES];
  self.navigationItem.leftBarButtonItem = nil;
  self.navigationItem.rightBarButtonItem = editButton;
  [spinner stopAnimating];
  [self clearHelperControllers];
  // TODO: cancel request?
}

- (void) clearHelperControllers {
  [activityCommentsDialogController release];
  [activityDateDialogController release];
  [activityLengthDialogController release];
  [projectChoiceController release];
  activityCommentsDialogController = nil;
  activityDateDialogController = nil;
  activityLengthDialogController = nil;
  projectChoiceController = nil;
}

- (void) editClicked {
  [self setEditing: YES animated: YES];
  self.navigationItem.leftBarButtonItem = cancelButton;
  self.navigationItem.rightBarButtonItem = saveButton;
}

- (void) executeSave {
  [connector editActivity: activity];
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) activityEdited {
  [self setEditing: NO animated: YES];
  self.navigationItem.leftBarButtonItem = nil;
  self.navigationItem.rightBarButtonItem = editButton;
  [spinner stopAnimating];
}

- (void) activityDeleted {
  [self.navigationController popViewControllerAnimated: YES];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) table {
  return 2;
}

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  if (section == 0) {
    return 4; // TODO: 5 if activity author is displayed too
  } else {
    return (self.editing ? 1 : 0);
  }
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  if (path.section == 0) {
    //if (path.row == 3) {
    //  return commentsCell;
    //} else {
      UITableViewCell *cell = [self tableView: table fieldCellForRow: path.row];
      cell.accessoryType = UITableViewCellAccessoryNone;
      cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
      return cell;
    //}
  } else {
    UITableViewCell *cell = [table cellWithStyle: UITableViewCellStyleDefault andIdentifier: DELETE_ACTIVITY_CELL_TYPE];
    cell.textLabel.text = @"Delete activity";
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.textLabel.textColor = [UIColor colorWithRed: 0.7 green: 0.0 blue: 0.0 alpha: 1.0];
    return cell;
  }
}

- (UITableViewCellEditingStyle) tableView: (UITableView *) table
            editingStyleForRowAtIndexPath: (NSIndexPath *) path {
  return UITableViewCellEditingStyleNone;
}

- (BOOL) tableView: (UITableView *) table
         shouldIndentWhileEditingRowAtIndexPath: (NSIndexPath *) path {
  return NO;
}

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  if (self.editing) {
    if (path.section == 0) {
      [self pushHelperControllerForPath: path];
    } else {
      [self deleteActivityClicked];
    }
  } else {
    [table deselectRowAtIndexPath: path animated: YES];
  }
}

- (UIViewController *) helperControllerForRow: (NSInteger) row {
  switch (row) {
    case 0: return [self activityDateDialogController];
    case 1: return [self projectChoiceController];
    case 2: return [self activityLengthDialogController];
    case 3: return [self activityCommentsDialogController];
    default: return nil;
  }
}

- (void) setEditing: (BOOL) editing animated: (BOOL) animated {
  [super setEditing: editing animated: animated];
  [tableView beginUpdates];
  [tableView setEditing: editing animated: animated];
  NSArray *indexes = RTArray(RTIndex(1, 0));
  if (editing) {
    [tableView insertRowsAtIndexPaths: indexes withRowAnimation: UITableViewRowAnimationNone];
  } else {
    [tableView deleteRowsAtIndexPaths: indexes withRowAnimation: UITableViewRowAnimationNone];
  }
  [tableView endUpdates];
}

@end
