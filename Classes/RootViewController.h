//
//  RootViewController.h
//  RubyTime
//
//  Created by Jakub Suder on 27-04-09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginDialogController;
@class RubyTimeConnector;

@interface RootViewController : UITableViewController {
  LoginDialogController *loginController;
  RubyTimeConnector *connector;
  NSMutableArray *activities;
}

- (void) loginSuccessful;

@end
