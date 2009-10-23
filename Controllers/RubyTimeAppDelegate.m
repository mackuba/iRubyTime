// -------------------------------------------------------
// RubyTimeAppDelegate.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "ActivityListController.h"
#import "LoginDialogController.h"
#import "RubyTimeAppDelegate.h"
#import "RubyTimeConnector.h"
#import "Utils.h"

#define USERNAME_SETTING @"username"
#define PASSWORD_SETTING @"password"
#define SERVER_SETTING @"serverURL"
#define USER_TYPE_SETTING @"userType"


@interface RubyTimeAppDelegate()
- (void) buildGuiForUserType: (UserType) type;
- (void) initApplication;
- (void) saveAccountData;
- (Account *) loadAccountData;
- (NSArray *) viewControllersForUserType: (UserType) type;
- (NSArray *) viewControllerClassesForUserType: (UserType) type;
@end


@implementation RubyTimeAppDelegate

@synthesize window, tabBarController, currentController;
OnDeallocRelease(window, tabBarController, connector, currentController);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (void) initApplication {
  connector = [[RubyTimeConnector alloc] initWithAccount: [self loadAccountData]];

  Observe(connector, AuthenticationSuccessfulNotification, loginSuccessful);
  if ([connector.account canLogIn]) {
    [self buildGuiForUserType: connector.account.userType];
    [currentController showLoadingMessage];
    [connector authenticate];
  } else {
    currentController.connector = connector;
    [currentController showPopupView: [LoginDialogController class]];
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

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

- (void) buildGuiForUserType: (UserType) type {
  NSArray *viewControllers = [self viewControllersForUserType: type];
  NSMutableArray *navigationControllers = [[NSMutableArray alloc] initWithCapacity: viewControllers.count];
  for (BaseViewController *actualController in viewControllers) {
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController: actualController];
    [navigationControllers addObject: navigation];
    [navigation release];
  }
  [tabBarController setViewControllers: navigationControllers animated: NO];
  [navigationControllers release];
  self.currentController = (BaseViewController *) [viewControllers objectAtIndex: 0];
}

- (NSArray *) viewControllersForUserType: (UserType) type {
  NSArray *classes = [self viewControllerClassesForUserType: type];
  NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity: classes.count];
  for (Class controllerClass in classes) {
    BaseViewController *controller = [[[controllerClass alloc] initWithConnector: connector] autorelease];
    [controllers addObject: controller];
  }
  return [controllers autorelease];
}

- (NSArray *) viewControllerClassesForUserType: (UserType) type {
  // TODO: add switch and more options
  return RTArray([ActivityListController class]);
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) loginSuccessful {
  if (currentController.modalViewController) {
    // login controller was shown previously
    [self saveAccountData];
    [currentController hidePopupView];
    [self buildGuiForUserType: connector.account.userType];
    [currentController showLoadingMessage];
  }
  // TODO: handle the case where a user's type was changed in the meantime
  Observe(connector, ProjectsReceivedNotification, projectsReceived);
  [connector loadProjects];
}

- (void) projectsReceived {
  // TODO: load users too (unless type == employee)
  StopObservingAll();
  if ([currentController needsOwnData]) {
    [currentController fetchData];
  } else {
    [currentController initializeView];
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark UIApplication callbacks

- (void) applicationDidFinishLaunching: (UIApplication *) application {
  [window addSubview: [tabBarController view]];
  [window makeKeyAndVisible];
  [self initApplication];
}

@end
