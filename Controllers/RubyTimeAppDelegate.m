// -------------------------------------------------------
// RubyTimeAppDelegate.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "ActivityListController.h"
#import "RubyTimeAppDelegate.h"
#import "RubyTimeConnector.h"
#import "Utils.h"

#define USERNAME_SETTING @"username"
#define PASSWORD_SETTING @"password"
#define SERVER_SETTING @"serverURL"
#define USER_TYPE_SETTING @"userType"


@interface RubyTimeAppDelegate()
- (void) initApplication;
- (Account *) loadAccountData;
- (void) saveAccountData;
@end

@implementation RubyTimeAppDelegate

@synthesize window, tabBarController, activityListController;
OnDeallocRelease(window, tabBarController, connector, activityListController);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (void) initApplication {
  connector = [[RubyTimeConnector alloc] initWithAccount: [self loadAccountData]];
  activityListController.connector = connector;

  Observe(connector, AuthenticationSuccessfulNotification, loginSuccessful);
  if ([connector.account canLogIn]) {
    [connector authenticate];
  }
  // else -> activity list controller will show the login screen
}

- (Account *) loadAccountData {
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  NSString *username = [settings objectForKey: USERNAME_SETTING];
  NSString *serverURL = [settings objectForKey: SERVER_SETTING];
  NSString *userType = [settings objectForKey: USER_TYPE_SETTING];
  NSString *password = [settings passwordForKey: PASSWORD_SETTING andUsername: username];
  Account *account = [[Account alloc] initWithServerURL: serverURL username: username password: password];
  [account setUserTypeFromString: userType];
  return [account autorelease];
}

// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

- (void) saveAccountData {
  NSString *username = connector.account.username;
  NSString *password = connector.account.password;
  NSString *serverURL = connector.account.serverURL;
  NSString *userType = [connector.account userTypeToString];
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  [settings setObject: username forKey: USERNAME_SETTING];
  [settings setObject: serverURL forKey: SERVER_SETTING];
  [settings setObject: userType forKey: USER_TYPE_SETTING];
  [settings setPassword: password forKey: PASSWORD_SETTING andUsername: username];
  [settings synchronize];
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) loginSuccessful {
  [self saveAccountData];
  Observe(connector, ProjectsReceivedNotification, projectsReceived);
  [connector loadProjects];
}

- (void) projectsReceived {
  [connector loadActivities];
}

// -------------------------------------------------------------------------------------------
#pragma mark UIApplication callbacks

- (void) applicationDidFinishLaunching: (UIApplication *) application {
  [self initApplication];
  [window addSubview: [tabBarController view]];
  [window makeKeyAndVisible];
}

@end
