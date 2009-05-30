// -------------------------------------------------------
// LoginDialogController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class RubyTimeConnector;
@class SFHFEditableCell;

@interface LoginDialogController : UITableViewController <UITextFieldDelegate> {
  UITextField *urlField;
  UITextField *usernameField;
  UITextField *passwordField;
  UIActivityIndicatorView *spinner;
  UIView *footerView;
  UIButton *loginButton;
  RubyTimeConnector *connector;
}

@property (nonatomic, retain) IBOutlet UIView *footerView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;

- (id) initWithConnector: (RubyTimeConnector *) rtConnector;
- (IBAction) loginPressed;
- (void) setupCell: (SFHFEditableCell *) cell forRow: (NSInteger) row;

@end
