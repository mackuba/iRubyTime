#import <UIKit/UIKit.h>

@class LoginDialogController;
@class RubyTimeConnector;

@interface ActivityListController : UITableViewController {
  LoginDialogController *loginController;
  RubyTimeConnector *connector;
  NSMutableArray *activities;
}

- (void) loginSuccessful;

@end
