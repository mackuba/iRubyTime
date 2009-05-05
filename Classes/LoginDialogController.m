// -------------------------------------------------------
// LoginDialogController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "ActivityListController.h"
#import "LoginDialogController.h"
#import "RubyTimeConnector.h"
#import "Utils.h"

@implementation LoginDialogController

@synthesize urlField, usernameField, passwordField, spinner;
OnDeallocRelease(urlField, usernameField, passwordField, spinner, connector);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (RubyTimeConnector *) rtConnector {
  self = [super initWithNibName: @"LoginDialog" bundle: [NSBundle mainBundle]];
  if (self) {
    connector = [rtConnector retain];
    Observe(connector, @"authenticationFailed", authenticationFailed);
  }
  return self;
}

- (void) viewDidAppear: (BOOL) animated {
  [urlField becomeFirstResponder];
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (IBAction) loginPressed {
  if (urlField.text.length > 0 && usernameField.text.length > 0 && passwordField.text.length > 0) {
    [urlField resignFirstResponder];
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
    [connector setServerURL: urlField.text username: usernameField.text password: passwordField.text];
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
  [spinner stopAnimating];
  [Utils showAlertWithTitle: @"Error" content: @"Incorrect username or password."];
}

@end
