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
  BOOL displaysActivityUser;
  UIView *lockedActivityInfo;
}

@property (nonatomic) BOOL displaysActivityUser;
@property (nonatomic, retain) IBOutlet UIView *lockedActivityInfo;

- (id) initWithActivity: (Activity *) activity connector: (ServerConnector *) connector;

@end
