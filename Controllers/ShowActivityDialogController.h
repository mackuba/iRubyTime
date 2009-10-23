// -------------------------------------------------------
// ShowActivityDialogController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>
#import "ActivityDetailsController.h"

@interface ShowActivityDialogController : ActivityDetailsController <UIActionSheetDelegate> {
  Activity *originalActivity;
  UIBarButtonItem *editButton;
}

- (id) initWithActivity: (Activity *) activity
              connector: (RubyTimeConnector *) connector
        activityManager: (ActivityManager *) manager;

@end
