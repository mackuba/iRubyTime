// -------------------------------------------------------
// RubyTimeAppDelegate.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

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
- (RubyTimeConnector *) newConnector;
@end

@implementation RubyTimeAppDelegate

@synthesize window, navigationController, activityListController;
OnDeallocRelease(window, navigationController, connector, activityListController);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (void) initApplication {
  connector = [self newConnector];
  activityListController.connector = connector;
  
  Observe(connector, AuthenticationSuccessfulNotification, loginSuccessful);
  Observe(connector, ProjectsReceivedNotification, projectsReceived);
}

- (RubyTimeConnector *) newConnector {
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
  return [[RubyTimeConnector alloc] initWithServerURL: serverURL username: username password: password];
}

// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

- (void) saveLoginAndPassword {
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  [settings setObject: connector.username forKey: USERNAME_SETTING];
  [settings setObject: connector.serverURL forKey: SERVER_SETTING];

  #if TARGET_IPHONE_SIMULATOR
    [settings setObject: connector.password forKey: PASSWORD_SETTING];
  #else
    NSError *error;
    [SFHFKeychainUtils storeUsername: connector.username
                         andPassword: connector.password
                      forServiceName: KEYCHAIN_SERVICE_NAME
                      updateExisting: YES
                               error: &error];
  #endif

  [settings synchronize];
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) loginSuccessful {
  [self saveLoginAndPassword];
  // give the activity list controller some time to hide the login dialog...
  [connector performSelector: @selector(loadProjects) withObject: NULL afterDelay: 0.5];
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

@end
