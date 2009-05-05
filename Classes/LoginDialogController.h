// -------------------------------------------------------
// LoginDialogController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class RubyTimeConnector;

@interface LoginDialogController : UIViewController <UITextFieldDelegate> {
  UITextField *urlField;
  UITextField *usernameField;
  UITextField *passwordField;
  UIActivityIndicatorView *spinner;
  RubyTimeConnector *connector;
}

@property (nonatomic, retain) IBOutlet UITextField *urlField;
@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

- (id) initWithConnector: (RubyTimeConnector *) rtConnector;
- (IBAction) loginPressed;

@end
