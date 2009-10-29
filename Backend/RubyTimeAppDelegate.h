// -------------------------------------------------------
// RubyTimeAppDelegate.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class ActivityListController;
@class BaseViewController;
@class RubyTimeConnector;

@interface RubyTimeAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
  UIWindow *window;
  UITabBarController *tabBarController;
  BaseViewController *currentController;
  RubyTimeConnector *connector;
  BOOL initialDataIsLoaded;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet BaseViewController *currentController;

@end
