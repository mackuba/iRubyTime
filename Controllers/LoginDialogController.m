// -------------------------------------------------------
// LoginDialogController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "ActivityListController.h"
#import "LoginDialogController.h"
#import "ServerConnector.h"
#import "SFHFEditableCell.h"
#import "Utils.h"


@interface LoginDialogController ()
- (void) showError: (NSString *) message;
@end


@implementation LoginDialogController

@synthesize spinner, footerView, loginButton;
PSReleaseOnDealloc(connector, spinner, footerView, loginButton);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (ServerConnector *) rtConnector {
  self = [super initWithStyle: UITableViewStyleGrouped];
  if (self) {
    [[NSBundle mainBundle] loadNibNamed: @"LoginDialog" owner: self options: nil];
    connector = [rtConnector retain];
    PSObserve(connector, AuthenticationFailedNotification, authenticationFailed);
    PSObserve(connector, RequestFailedNotification, requestFailed:);
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
  PSStopObservingAll();
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orientation {
  return RTiPad;
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (IBAction) loginPressed {
  if (urlField.text.length > 0 && usernameField.text.length > 0 && passwordField.text.length > 0) {
    [urlField resignFirstResponder];
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
    [loginButton setEnabled: NO];
    connector.account = [[[Account alloc] initWithServerURL: urlField.text
                                                   username: usernameField.text
                                                   password: passwordField.text] autorelease];
    [connector authenticate];
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
  [UIAlertView psShowErrorWithMessage: message];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  return 3;
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  SFHFEditableCell *cell = (SFHFEditableCell *) [table dequeueReusableCellWithIdentifier: PSGenericCell];
  if (!cell) {
    cell = [[SFHFEditableCell alloc] initWithReuseIdentifier: PSGenericCell delegate: self];
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
  cell.textField.adjustsFontSizeToFitWidth = YES;
  cell.textField.minimumFontSize = 8.0;
}

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  switch (path.row) {
    case 0: [urlField becomeFirstResponder]; break;
    case 1: [usernameField becomeFirstResponder]; break;
    case 2: [passwordField becomeFirstResponder]; break;
    default: break;
  }
  [table deselectRowAtIndexPath: path animated: NO];
}

@end
