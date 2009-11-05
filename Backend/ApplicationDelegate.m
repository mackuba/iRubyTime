// -------------------------------------------------------
// ApplicationDelegate.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "AllActivitiesController.h"
#import "ApplicationDelegate.h"
#import "LoginDialogController.h"
#import "ProjectListController.h"
#import "SearchFormController.h"
#import "ServerConnector.h"
#import "SettingsController.h"
#import "UserActivitiesController.h"
#import "UserListController.h"
#import "Utils.h"

#define USERNAME_SETTING @"username"
#define PASSWORD_SETTING @"password"
#define SERVER_SETTING @"serverURL"
#define USER_TYPE_SETTING @"userType"


@interface ApplicationDelegate()
- (void) buildGuiForUserType: (UserType) type;
- (void) initApplication;
- (void) initialDataLoaded;
- (void) saveAccountData;
- (void) showLoginDialog;
- (Account *) loadAccountData;
- (NSArray *) viewControllersForUserType: (UserType) type;
- (NSArray *) viewControllerClassesForUserType: (UserType) type;
- (NSArray *) navigationControllersForUserType: (UserType) type;
@end


@implementation ApplicationDelegate

@synthesize window, tabBarController, currentController, initialDataIsLoaded;
OnDeallocRelease(window, tabBarController, connector, currentController);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (void) initApplication {
  connector = [[ServerConnector alloc] initWithAccount: [self loadAccountData]];
  [currentController setConnector: connector];

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
  NSArray *navigationControllers = [self navigationControllersForUserType: type];
  [tabBarController setViewControllers: navigationControllers animated: NO];
  self.currentController = [[[navigationControllers objectAtIndex: 0] viewControllers] objectAtIndex: 0];
}

- (void) rebuildGuiExceptLastControllerForUserType: (UserType) type {
  NSArray *tabs = tabBarController.viewControllers;
  UINavigationController *lastController = [tabs objectAtIndex: (tabs.count - 1)];
  NSMutableArray *navigationControllers = [[self navigationControllersForUserType: type] mutableCopy];
  [navigationControllers replaceObjectAtIndex: (navigationControllers.count - 1) withObject: lastController];
  [tabBarController setViewControllers: navigationControllers animated: NO];
  tabBarController.selectedIndex = 0;
  self.currentController = [[[navigationControllers objectAtIndex: 0] viewControllers] objectAtIndex: 0];
}

- (NSArray *) navigationControllersForUserType: (UserType) type {
  NSArray *viewControllers = [self viewControllersForUserType: type];
  NSMutableArray *navigationControllers = [[NSMutableArray alloc] initWithCapacity: viewControllers.count];
  for (BaseViewController *actualController in viewControllers) {
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController: actualController];
    [navigationControllers addObject: navigation];
    [navigation release];
  }
  return [navigationControllers autorelease];
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
      [UserListController class],
      [SearchFormController class],
      [SettingsController class]
    );
  } else {
    return RTArray(
      [AllActivitiesController class],
      [ProjectListController class],
      [SearchFormController class],
      [SettingsController class]
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
  if ([currentController modalViewController]) {
    // login controller was shown previously
    [currentController hidePopupView];
    [self buildGuiForUserType: connector.account.userType];
    [currentController showLoadingMessage];
  } else {
    // check if user's type wasn't changed in the meantime
    Account *oldAccount = [self loadAccountData];
    if (oldAccount.userType != connector.account.userType) {
      [self reloginSuccessful];
      return;
    }
  }
  [self saveAccountData];
  Observe(connector, ProjectsReceivedNotification, projectsReceived);
  [connector loadProjects];
}

- (void) reloginSuccessful {
  initialDataIsLoaded = NO;
  [self saveAccountData];
  [self rebuildGuiExceptLastControllerForUserType: connector.account.userType];
  [currentController hidePopupView];
  [currentController showLoadingMessage];
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
  [currentController fetchDataIfNeeded];
}

// -------------------------------------------------------------------------------------------
#pragma mark Delegate callbacks

- (void) tabBarController: (UITabBarController *) tabBarController
  didSelectViewController: (UIViewController *) viewController {

  UINavigationController *navigation = (UINavigationController *) viewController;
  self.currentController = [navigation topViewController];
}

- (void) applicationDidFinishLaunching: (UIApplication *) application {
  initialDataIsLoaded = NO;
  [window addSubview: [tabBarController view]];
  [window makeKeyAndVisible];
  [self initApplication];
}

@end
