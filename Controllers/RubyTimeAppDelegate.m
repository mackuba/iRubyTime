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
#import "SFHFKeychainUtils.h"
#import "Utils.h"

#define USERNAME_SETTING @"username"
#define PASSWORD_SETTING @"password"
#define SERVER_SETTING @"serverURL"
#define KEYCHAIN_SERVICE_NAME @"iRubyTime"

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

  #if TARGET_IPHONE_SIMULATOR
    NSString *password = [settings objectForKey: PASSWORD_SETTING];
  #else
    NSString *password = nil;
    NSError *error;
    if (username) {
      password = [SFHFKeychainUtils getPasswordForUsername: username
                                            andServiceName: KEYCHAIN_SERVICE_NAME
                                                     error: &error];
    }
  #endif
  return [[Account alloc] initWithServerURL: serverURL username: username password: password];
}

// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

- (void) saveAccountData {
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  [settings setObject: connector.account.username forKey: USERNAME_SETTING];
  [settings setObject: connector.account.serverURL forKey: SERVER_SETTING];

  #if TARGET_IPHONE_SIMULATOR
    [settings setObject: connector.account.password forKey: PASSWORD_SETTING];
  #else
    NSError *error;
    [SFHFKeychainUtils storeUsername: connector.account.username
                         andPassword: connector.account.password
                      forServiceName: KEYCHAIN_SERVICE_NAME
                      updateExisting: YES
                               error: &error];
  #endif

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
