// -------------------------------------------------------
// RubyTimeAppDelegate.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class RubyTimeConnector;
@class ActivityListController;

@interface RubyTimeAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
  UIWindow *window;
  UITabBarController *tabBarController;
  RubyTimeConnector *connector;
  ActivityListController *activityListController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet ActivityListController *activityListController;

@end
