// -------------------------------------------------------
// ApplicationDelegate.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>
#import "Account.h"

@class ActivityListController;
@class BaseViewController;
@class ServerConnector;

@interface ApplicationDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
  UIWindow *window;
  UITabBarController *tabBarController;
  id currentController;
  ServerConnector *connector;
  BOOL initialDataIsLoaded;
  BOOL kernelPanic;  // this means that something very bad has happened (e.g. server refused connection) :)
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet id currentController;
@property (nonatomic, readonly) BOOL initialDataIsLoaded;
@property (nonatomic, readonly) BOOL kernelPanic;

- (void) reloginSuccessful;

@end
