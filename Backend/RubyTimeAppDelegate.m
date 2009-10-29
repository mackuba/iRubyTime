// -------------------------------------------------------
// RubyTimeAppDelegate.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "AllActivitiesController.h"
#import "LoginDialogController.h"
#import "ProjectListController.h"
#import "RubyTimeAppDelegate.h"
#import "RubyTimeConnector.h"
#import "UserActivitiesController.h"
#import "UserListController.h"
#import "Utils.h"

#define USERNAME_SETTING @"username"
#define PASSWORD_SETTING @"password"
#define SERVER_SETTING @"serverURL"
#define USER_TYPE_SETTING @"userType"


@interface RubyTimeAppDelegate()
- (void) buildGuiForUserType: (UserType) type;
- (void) initializeCurrentController;
- (void) initApplication;
- (void) initialDataLoaded;
- (void) saveAccountData;
- (void) showLoginDialog;
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
  currentController.connector = connector;

  Observe(connector, AuthenticationSuccessfulNotification, loginSuccessful);
  if ([connector.account canLogIn]) {
    [self buildGuiForUserType: connector.account.userType];
    [currentController showLoadingMessage];
    Observe(connector, AuthenticationFailedNotification, loginFailed);
    [connector authenticate];
  } else {
    [self showLoginDialog];
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
  self.currentController = [viewControllers objectAtIndex: 0];
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
  if (type == Admin || type == ClientUser) {
    return RTArray(
      [AllActivitiesController class],
      [ProjectListController class],
      [UserListController class]
    );
  } else {
    return RTArray(
      [AllActivitiesController class],
      [ProjectListController class]
    );
  }
}

- (void) showLoginDialog {
  LoginDialogController *loginDialog = [[LoginDialogController alloc] initWithConnector: connector];
  [currentController showPopupView: loginDialog];
  [loginDialog release];
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) loginSuccessful {
  [self saveAccountData];
  if (currentController.modalViewController) {
    // login controller was shown previously
    [currentController hidePopupView];
    [self buildGuiForUserType: connector.account.userType];
    [currentController showLoadingMessage];
  }
  // TODO: handle the case where a user's type was changed in the meantime
  Observe(connector, ProjectsReceivedNotification, projectsReceived);
  [connector loadProjects];
}

- (void) loginFailed {
  [self showLoginDialog];
}

- (void) projectsReceived {
  if (connector.account.userType == Employee) {
    [self initialDataLoaded];
  } else {
    Observe(connector, UsersReceivedNotification, initialDataLoaded);
    [connector loadUsers];
  }
}

- (void) initialDataLoaded {
  StopObservingAll();
  initialDataIsLoaded = YES;
  [self initializeCurrentController];
}

- (void) initializeCurrentController {
  if (initialDataIsLoaded) {
    [connector dropCurrentConnection];
    [currentController fetchDataIfNeeded];
  } else {
    [currentController showLoadingMessage];
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Delegate callbacks

- (void) tabBarController: (UITabBarController *) tabBarController
  didSelectViewController: (UIViewController *) viewController {

  [currentController hideLoadingMessage];
  UINavigationController *navigation = (UINavigationController *) viewController;
  self.currentController = [[navigation viewControllers] objectAtIndex: 0];
  [self initializeCurrentController];
}

- (void) applicationDidFinishLaunching: (UIApplication *) application {
  initialDataIsLoaded = NO;
  [window addSubview: [tabBarController view]];
  [window makeKeyAndVisible];
  [self initApplication];
}

@end
