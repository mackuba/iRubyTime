// -------------------------------------------------------
// ActivityDetailsController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

#import "Activity.h"
#import "ActivityCommentsDialogController.h"
#import "ActivityDateDialogController.h"
#import "ActivityLengthDialogController.h"
#import "Project.h"
#import "ProjectChoiceController.h"
#import "Request.h"
#import "RubyTimeConnector.h"
#import "Utils.h"
#import "NSDictionary+BSJSONAdditions.h"

// ABSTRACT CLASS

@interface ActivityDetailsController : UIViewController {
  Activity *activity;
  ActivityCommentsDialogController *activityCommentsDialogController;
  ActivityDateDialogController *activityDateDialogController;
  ActivityLengthDialogController *activityLengthDialogController;
  ProjectChoiceController *projectChoiceController;
  RubyTimeConnector *connector;
  UIActivityIndicatorView *spinner;
  UIBarButtonItem *cancelButton;
  UIBarButtonItem *loadingButton;
  UIBarButtonItem *saveButton;
  UITableView *tableView;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (id) initWithConnector: (RubyTimeConnector *) rtConnector nibName: (NSString *) nib;
- (void) setupToolbar;
- (UITableViewCell *) tableView: (UITableView *) table fieldCellForRow: (NSInteger) row;
- (void) pushHelperControllerForPath: (NSIndexPath *) path;
- (NSString *) errorMessageFromJSON: (NSString *) jsonString;

- (ActivityCommentsDialogController *) activityCommentsDialogController;
- (ActivityDateDialogController *) activityDateDialogController;
- (ActivityLengthDialogController *) activityLengthDialogController;
- (ProjectChoiceController *) projectChoiceController;

// ABSTRACT METHODS
- (void) executeSave;
- (UIViewController *) helperControllerForRow: (NSInteger) row;

@end
