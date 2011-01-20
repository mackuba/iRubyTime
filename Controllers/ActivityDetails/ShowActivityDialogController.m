// -------------------------------------------------------
// ShowActivityDialogController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "ShowActivityDialogController.h"

#define DELETE_ACTIVITY_CELL_TYPE @"DeleteActivityCell"


@interface ShowActivityDialogController ()
- (void) deleteActivityClicked;
@end;


@implementation ShowActivityDialogController

@synthesize displaysActivityUser, lockedActivityInfo;
PSReleaseOnDealloc(originalActivity, editButton, lockedActivityInfo);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithActivity: (Activity *) anActivity connector: (ServerConnector *) rtConnector {
  self = [super initWithConnector: rtConnector nibName: @"ShowActivityDialog"];
  if (self) {
    activity = [anActivity copy];
    originalActivity = [anActivity retain];
    displaysActivityUser = NO;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  tableView.allowsSelectionDuringEditing = YES;
  if (activity.isLocked) {
    tableView.tableFooterView = lockedActivityInfo;
  }
  PSObserve(connector, ActivityUpdatedNotification, activityUpdated);
}

- (void) setupToolbar {
  [super setupToolbar];
  self.navigationItem.title = @"Activity details";
  [self psSetBackButtonTitle: @"Activity"];
  if ((connector.account.userType != ClientUser) && (!activity.isLocked)) {
    editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemEdit
                                                               target: self
                                                               action: @selector(editClicked)];
    self.navigationItem.rightBarButtonItem = editButton;
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) deleteActivityClicked {
  UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle: @"Do you really want to delete this activity?"
                                                     delegate: self
                                            cancelButtonTitle: @"Cancel"
                                       destructiveButtonTitle: @"Delete"
                                            otherButtonTitles: nil];
  [sheet setActionSheetStyle: UIActionSheetStyleDefault];
  [sheet showInView: [self.view.window.subviews objectAtIndex: 0]];
  [sheet release];
}

- (void) actionSheet: (UIActionSheet *) sheet clickedButtonAtIndex: (NSInteger) index {
  if (index == 0) {
    cancelButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = loadingButton;
    [spinner startAnimating];
    [connector deleteActivity: activity];
  }
  [tableView deselectRowAtIndexPath: PSIndex(1, 0) animated: YES];
}

- (void) cancelClicked {
  [activity release];
  activity = [originalActivity copy];
  [tableView reloadData];
  [self setEditing: NO animated: YES];
  self.navigationItem.leftBarButtonItem = nil;
  self.navigationItem.rightBarButtonItem = editButton;
  [subcontrollers removeAllObjects];
}

- (void) editClicked {
  [self setEditing: YES animated: YES];
  self.navigationItem.leftBarButtonItem = cancelButton;
  self.navigationItem.rightBarButtonItem = saveButton;
}

- (void) executeSave {
  [connector updateActivity: activity];
  originalActivity = [activity retain];
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) activityUpdated {
  [self setEditing: NO animated: YES];
  cancelButton.enabled = YES;
  self.navigationItem.leftBarButtonItem = nil;
  self.navigationItem.rightBarButtonItem = editButton;
  [spinner stopAnimating];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (PSIntArray *) rowTypesInSection: (NSInteger) section {
  if (section == 0) {
    if (displaysActivityUser) {
      if ([activity.project hasAvailableActivityTypes]) {
        return PSIntegers(DateRow, ProjectRow, ActivityTypeRow, UserRow, LengthRow, CommentsRow);
      } else {
        return PSIntegers(DateRow, ProjectRow, UserRow, LengthRow, CommentsRow);
      }
    } else {
      if ([activity.project hasAvailableActivityTypes]) {
        return PSIntegers(DateRow, ProjectRow, ActivityTypeRow, LengthRow, CommentsRow);
      } else {
        return PSIntegers(DateRow, ProjectRow, LengthRow, CommentsRow);
      }
    }
  } else {
    if (self.editing) {
      return PSIntegers(DeleteButtonRow);
    } else {
      return [PSIntArray emptyArray];
    }
  }
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) table {
  return (activity.isLocked) ? 1 : 2;
}

- (UITableViewCell *) cellForRowType: (RowType) rowType {
  UITableViewCell *cell;
  if (rowType == DeleteButtonRow) {
    cell = [tableView psCellWithStyle: UITableViewCellStyleDefault andIdentifier: DELETE_ACTIVITY_CELL_TYPE];
    cell.textLabel.text = @"Delete activity";
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.textLabel.textColor = [UIColor colorWithRed: 0.7 green: 0.0 blue: 0.0 alpha: 1.0];
  } else {
    cell = [super cellForRowType: rowType];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.editingAccessoryType =
     (rowType == UserRow) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
  }
  return cell;
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
      if ([self rowTypeAtIndexPath: path] != UserRow) {
        [super tableView: table didSelectRowAtIndexPath: path];
      } else {
        [table deselectRowAtIndexPath: path animated: YES];
      }
    } else {
      [self deleteActivityClicked];
    }
  } else {
    [table deselectRowAtIndexPath: path animated: YES];
  }
}

- (void) setEditing: (BOOL) editing animated: (BOOL) animated {
  [super setEditing: editing animated: animated];
  [tableView beginUpdates];
  [tableView setEditing: editing animated: animated];
  NSArray *indexes = PSArray(PSIndex(1, 0));
  if (editing) {
    [tableView insertRowsAtIndexPaths: indexes withRowAnimation: UITableViewRowAnimationNone];
  } else {
    [tableView deleteRowsAtIndexPaths: indexes withRowAnimation: UITableViewRowAnimationNone];
  }
  [tableView endUpdates];
}

@end
