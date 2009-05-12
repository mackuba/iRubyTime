// -------------------------------------------------------
// RubyTimeAppDelegate.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "ActivityListController.h"
#import "RubyTimeAppDelegate.h"
#import "RubyTimeConnector.h"
#import "Utils.h"

@interface RubyTimeAppDelegate()
- (void) initApplication;
@end

@implementation RubyTimeAppDelegate

@synthesize window, navigationController, activityListController;
OnDeallocRelease(window, navigationController, connector, activityListController);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (void) initApplication {
  connector = [[RubyTimeConnector alloc] init]; // TODO: load password if possible
  activityListController.connector = connector;
  Observe(connector, @"authenticationSuccessful", loginSuccessful);
  Observe(connector, @"projectsReceived", projectsReceived);
  // TODO: send auth request if password is set
  // TODO: save activities to file when they're received
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) loginSuccessful {
  // TODO: save login & password
  [connector loadProjects];
}

- (void) projectsReceived {
  [connector updateActivities];
}

// -------------------------------------------------------------------------------------------
#pragma mark UIApplication callbacks

- (void) applicationDidFinishLaunching: (UIApplication *) application {
  [self initApplication];
  [window addSubview: [navigationController view]];
  [window makeKeyAndVisible];
}

- (void) applicationWillTerminate: (UIApplication *) application {
  // TODO: save data
}

@end
