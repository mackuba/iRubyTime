// -------------------------------------------------------
// RubyTimeAppDelegate.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class RubyTimeConnector;
@class ActivityListController;

@interface RubyTimeAppDelegate : NSObject <UIApplicationDelegate> {
  UIWindow *window;
  UINavigationController *navigationController;
  RubyTimeConnector *connector;
  ActivityListController *activityListController;
  NSString *dataFile;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet ActivityListController *activityListController;

@end
