// -------------------------------------------------------
// RubyTimeAppDelegate.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@interface RubyTimeAppDelegate : NSObject <UIApplicationDelegate> {
  UIWindow *window;
  UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
