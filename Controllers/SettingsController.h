// -------------------------------------------------------
// SettingsController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class Account;

@interface SettingsController : BaseViewController {
  Account *currentAccount;
}

@end
