//
//  RootViewController.h
//  RubyTime
//
//  Created by Jakub Suder on 27-04-09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginDialogController;

@interface RootViewController : UITableViewController {
  LoginDialogController *loginController;
}

- (void) loginSuccessful;

@end
