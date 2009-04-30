// -------------------------------------------------------
// RubyTimeAppDelegate.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "RubyTimeAppDelegate.h"
#import "ActivityListController.h"
#import "Utils.h"

@implementation RubyTimeAppDelegate

SynthesizeAndReleaseLater(window, navigationController);

- (void) applicationDidFinishLaunching: (UIApplication *) application {
  // Configure and show the window
  [window addSubview: [navigationController view]];
  [window makeKeyAndVisible];
}

- (void) applicationWillTerminate: (UIApplication *) application {
  // Save data if appropriate
}

@end
