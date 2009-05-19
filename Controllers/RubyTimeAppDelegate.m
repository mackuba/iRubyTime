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

#define USERNAME_SETTING @"username"
#define PASSWORD_SETTING @"password"
#define SERVER_SETTING @"serverURL"

@interface RubyTimeAppDelegate()
- (void) initApplication;
- (void) loadDataFromDisk;
@end

@implementation RubyTimeAppDelegate

@synthesize window, navigationController, activityListController;
OnDeallocRelease(window, navigationController, connector, activityListController);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (void) initApplication {
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  NSString *username = [settings objectForKey: USERNAME_SETTING];
  NSString *password = [settings objectForKey: PASSWORD_SETTING];
  NSString *serverURL = [settings objectForKey: SERVER_SETTING];
  connector = [[RubyTimeConnector alloc] initWithServerURL: serverURL username: username password: password];
  activityListController.connector = connector;
  
  NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  dataFile = [[[dirs objectAtIndex: 0] stringByAppendingPathComponent: @"activities.data"] retain];
  
  [self loadDataFromDisk];
  
  Observe(connector, @"authenticationSuccessful", loginSuccessful);
  Observe(connector, @"projectsReceived", projectsReceived);
  Observe(connector, @"activitiesReceived", activitiesReceived);
}

// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

- (void) saveLoginAndPassword {
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  [settings setObject: connector.username forKey: USERNAME_SETTING];
  [settings setObject: connector.password forKey: PASSWORD_SETTING]; // TODO: encode password
  [settings setObject: connector.serverURL forKey: SERVER_SETTING];
  [settings synchronize];
}

- (void) saveDataToDisk {
  NSDictionary *data = RTDict(connector.projects, @"projects", connector.activities, @"activities");
  BOOL ok = [NSKeyedArchiver archiveRootObject: data toFile: dataFile];
  NSLog(@"saved data %@", ok ? @"OK" : @"ERROR");
}

- (void) loadDataFromDisk {
  NSDictionary *data = [NSKeyedUnarchiver unarchiveObjectWithFile: dataFile];
  if (data) {
    connector.activities = [data objectForKey: @"activities"];
    connector.projects = [data objectForKey: @"projects"];
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) loginSuccessful {
  [self saveLoginAndPassword];
  [connector loadProjects];
}

- (void) projectsReceived {
  [connector updateActivities];
}

- (void) activitiesReceived {
  [self saveDataToDisk];
}

// -------------------------------------------------------------------------------------------
#pragma mark UIApplication callbacks

- (void) applicationDidFinishLaunching: (UIApplication *) application {
  [self initApplication];
  [window addSubview: [navigationController view]];
  [window makeKeyAndVisible];
}

@end
