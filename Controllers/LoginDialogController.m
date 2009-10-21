// -------------------------------------------------------
// LoginDialogController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "ActivityListController.h"
#import "LoginDialogController.h"
#import "RubyTimeConnector.h"
#import "SFHFEditableCell.h"
#import "Utils.h"

#define LOGIN_DIALOG_CELL_TYPE @"LoginDialogCell"

@interface LoginDialogController ()
- (void) showError: (NSString *) message;
@end

@implementation LoginDialogController

@synthesize spinner, footerView, loginButton;
OnDeallocRelease(connector, spinner, footerView, loginButton);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (RubyTimeConnector *) rtConnector {
  self = [super initWithStyle: UITableViewStyleGrouped];
  if (self) {
    [[NSBundle mainBundle] loadNibNamed: @"LoginDialog" owner: self options: nil];
    connector = [rtConnector retain];
    Observe(connector, AuthenticationFailedNotification, authenticationFailed);
    Observe(connector, RequestFailedNotification, requestFailed:);
  }
  return self;
}

- (void) viewDidLoad {
  self.title = @"Log in to RubyTime";
  self.tableView.scrollEnabled = NO;
  self.tableView.tableFooterView = footerView;
}

- (void) viewDidAppear: (BOOL) animated {
  [urlField becomeFirstResponder];
}

- (void) viewWillDisappear: (BOOL) animated {
  StopObservingAll();
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (IBAction) loginPressed {
  if (urlField.text.length > 0 && usernameField.text.length > 0 && passwordField.text.length > 0) {
    [urlField resignFirstResponder];
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
    [loginButton setEnabled: NO];
    Account *account = [[Account alloc] initWithServerURL: urlField.text
                                                 username: usernameField.text
                                                 password: passwordField.text];
    [connector authenticateWithAccount: account];
    [spinner startAnimating];
  }
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField {
  if (textField.text.length == 0) {
    return NO;
  } else {
    if (textField == urlField) {
      [usernameField becomeFirstResponder];
    } else if (textField == usernameField) {
      [passwordField becomeFirstResponder];
    } else if (textField == passwordField) {
      [textField resignFirstResponder];
      [self loginPressed];
    }
    return YES;
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) authenticationFailed {
  [self showError: @"Incorrect username or password."];
}

- (void) requestFailed: (NSNotification *) notification {
  NSError *error = [notification.userInfo objectForKey: @"error"];
  [self showError: (error ? [error friendlyDescription] : @"Can't connect to the server.")];
}

- (void) showError: (NSString *) message {
  [spinner stopAnimating];
  [loginButton setEnabled: YES];
  [UIAlertView showAlertWithTitle: @"Error" content: message];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  return 3;
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  SFHFEditableCell *cell = (SFHFEditableCell *) [table dequeueReusableCellWithIdentifier: LOGIN_DIALOG_CELL_TYPE];
  if (!cell) {
    cell = [[SFHFEditableCell alloc] initWithReuseIdentifier: LOGIN_DIALOG_CELL_TYPE delegate: self];
  }
  [self setupCell: cell forRow: path.row];
  return cell;
}

- (void) setupCell: (SFHFEditableCell *) cell forRow: (NSInteger) row {
  switch (row) {
    case 0:
      [cell setLabelText: @"Server URL" andPlaceholderText: @"rubytime.org"];
      cell.textField.keyboardType = UIKeyboardTypeURL;
      cell.textField.returnKeyType = UIReturnKeyNext;
      cell.textField.secureTextEntry = NO;
      urlField = cell.textField;
      urlField.text = connector.account.serverURL;
      break;

    case 1:
      [cell setLabelText: @"Username" andPlaceholderText: @"john.smith"];
      cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
      cell.textField.returnKeyType = UIReturnKeyNext;
      cell.textField.secureTextEntry = NO;
      usernameField = cell.textField;
      usernameField.text = connector.account.username;
      break;

    case 2:
      [cell setLabelText: @"Password" andPlaceholderText: @"secret"];
      cell.textField.keyboardType = UIKeyboardTypeASCIICapable;
      cell.textField.returnKeyType = UIReturnKeyGo;
      cell.textField.secureTextEntry = YES;
      passwordField = cell.textField;
      break;
  }
  cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
  cell.textField.enablesReturnKeyAutomatically = YES;
}

@end
