#import <UIKit/UIKit.h>

@class RubyTimeConnector;
@class RootViewController;

@interface LoginDialogController : UIViewController <UITextFieldDelegate> {
  UITextField *urlField;
  UITextField *usernameField;
  UITextField *passwordField;
  UIActivityIndicatorView *spinner;
  RubyTimeConnector *connector;
  __weak RootViewController *mainController;
}

@property (nonatomic, retain) IBOutlet UITextField *urlField;
@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

- (id) initWithNibName: (NSString *) nibName
                bundle: (NSBundle *) bundle
             connector: (RubyTimeConnector *) rtConnector
        mainController: (RootViewController *) controller;

- (IBAction) loginPressed;

@end
