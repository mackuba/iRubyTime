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

@synthesize displaysActivityUser;
OnDeallocRelease(originalActivity, editButton);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithActivity: (Activity *) anActivity
              connector: (RubyTimeConnector *) rtConnector
        activityManager: (ActivityManager *) manager {
  self = [super initWithConnector: rtConnector nibName: @"ShowActivityDialog" activityManager: manager];
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
  Observe(connector, ActivityUpdatedNotification, activityUpdated);
  Observe(connector, ActivityDeletedNotification, activityDeleted);
}

- (void) setupToolbar {
  [super setupToolbar];
  self.navigationItem.title = @"Activity details";
  if (connector.account.userType != ClientUser) {
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
  [sheet showInView: self.view.window];
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

- (void) editClicked {
  [self setEditing: YES animated: YES];
  self.navigationItem.leftBarButtonItem = cancelButton;
  self.navigationItem.rightBarButtonItem = saveButton;
}

- (void) executeSave {
  [connector updateActivity: activity];
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) activityUpdated {
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

- (IntArray *) rowTypesInSection: (NSInteger) section {
  if (section == 0) {
    if (displaysActivityUser) {
      return [IntArray arrayOfSize: 5 integers: DateRow, ProjectRow, UserRow, LengthRow, CommentsRow];
    } else {
      return [IntArray arrayOfSize: 4 integers: DateRow, ProjectRow, LengthRow, CommentsRow];
    }
  } else {
    if (self.editing) {
      return [IntArray arrayOfSize: 1 integers: DeleteButtonRow];
    } else {
      return [IntArray emptyArray];
    }
  }
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) table {
  return 2;
}

- (UITableViewCell *) cellForRowType: (RowType) rowType {
  UITableViewCell *cell;
  if (rowType == DeleteButtonRow) {
    cell = [tableView cellWithStyle: UITableViewCellStyleDefault andIdentifier: DELETE_ACTIVITY_CELL_TYPE];
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

- (CGFloat) heightForRowOfType: (RowType) rowType {
  if (rowType == CommentsRow) {
    CGSize rect = [activity.comments sizeWithFont: commentsLabel.font
                                constrainedToSize: CGSizeMake(commentsLabel.bounds.size.width, 200)
                                    lineBreakMode: UILineBreakModeWordWrap];
    CGFloat requiredHeight = rect.height + 2 * commentsLabel.frame.origin.y + 5;
    return MAX(STANDARD_CELL_HEIGHT, requiredHeight);
  } else {
    return STANDARD_CELL_HEIGHT;
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
  NSArray *indexes = RTArray(RTIndex(1, 0));
  if (editing) {
    [tableView insertRowsAtIndexPaths: indexes withRowAnimation: UITableViewRowAnimationNone];
  } else {
    [tableView deleteRowsAtIndexPaths: indexes withRowAnimation: UITableViewRowAnimationNone];
  }
  [tableView endUpdates];
}

@end
