#import "LoginDialogController.h"
#import "RootViewController.h"
#import "RubyTimeConnector.h"
#import "Utils.h"

@implementation LoginDialogController

@synthesize urlField, usernameField, passwordField, spinner;
OnDeallocRelease(urlField, usernameField, passwordField, spinner, connector);

// -------------------------------------------------------------------------------------------
#pragma mark Initializers

- (id) initWithNibName: (NSString *) nibName
                bundle: (NSBundle *) bundle
             connector: (RubyTimeConnector *) rtConnector
        mainController: (RootViewController *) controller {
  if (self = [super initWithNibName: nibName bundle: bundle]) {
    connector = [rtConnector retain];
    connector.delegate = self;
    mainController = controller;
  }
  return self;
}

// -------------------------------------------------------------------------------------------
#pragma mark View initialization

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void) viewDidAppear: (BOOL) animated {
  [urlField becomeFirstResponder];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (IBAction) loginPressed {
  if (urlField.text.length > 0 && usernameField.text.length > 0 && passwordField.text.length > 0) {
    [urlField resignFirstResponder];
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
    [connector setServerURL: urlField.text username: usernameField.text password: passwordField.text];
    // [connector authenticate];
    [spinner startAnimating];
    
    // just for testing
    [self performSelector: @selector(authenticationSuccessful) withObject: nil afterDelay: 2.0];
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
#pragma mark RubyTimeConnector delegate callbacks

- (void) authenticationSuccessful {
  [mainController loginSuccessful];
}

- (void) authenticationFailed {
  [spinner stopAnimating];
  [Utils showAlertWithTitle: @"Error" content: @"Incorrect username or password."];
}

// -------------------------------------------------------------------------------------------
#pragma mark Cleaning up

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  // Release anything that's not essential, such as cached data
}

@end
