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

@interface ApplicationDelegate()
- (void) buildGuiForUserType: (UserType) type;
- (void) initApplication;
- (void) initialDataLoaded;
- (void) showLoginDialog;
- (NSArray *) viewControllersForUserType: (UserType) type;
- (NSArray *) viewControllerClassesForUserType: (UserType) type;
- (NSArray *) navigationControllersForUserType: (UserType) type;
@end

@implementation ApplicationDelegate

@synthesize window, tabBarController, currentController, initialDataIsLoaded, kernelPanic;
PSReleaseOnDealloc(window, tabBarController, connector, currentController);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (void) initApplication {
  connector = [[ServerConnector alloc] init];
  [currentController setConnector: connector];
  [PSConnector setSharedConnector: connector];

  PSObserve(connector, AuthenticationSuccessfulNotification, loginSuccessful);
  PSObserve(connector, RequestFailedNotification, requestFailed);
  if ([connector.account hasAllRequiredProperties]) {
    [self buildGuiForUserType: [connector.account userType]];
    [currentController showLoadingMessage];
    PSObserve(connector, AuthenticationFailedNotification, loginFailed);
    [[connector authenticateRequest] send];
  } else {
    [self showLoginDialog];
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

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
  [navigationControllers release];
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
    return PSArray(
      [AllActivitiesController class],
      [ProjectListController class],
      [UserListController class],
      [SearchFormController class],
      [SettingsController class]
    );
  } else {
    return PSArray(
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
    [self buildGuiForUserType: [connector.account userType]];
    [currentController showLoadingMessage];
  } else {
    // check if user's type wasn't changed in the meantime
    Account *oldAccount = [Account accountFromSettings];
    if (oldAccount.userType != [connector.account userType]) {
      [self reloginSuccessful];
      return;
    }
  }
  [connector.account save];
  PSObserve(connector, ProjectsReceivedNotification, projectsReceived);
  [[connector loadProjectsRequest] send];
}

- (void) reloginSuccessful {
  initialDataIsLoaded = NO;
  kernelPanic = NO;
  [connector.account save];
  [self rebuildGuiExceptLastControllerForUserType: [connector.account userType]];
  [currentController hidePopupView];
  [currentController showLoadingMessage];
  PSObserve(connector, RequestFailedNotification, requestFailed);
  PSObserve(connector, ProjectsReceivedNotification, projectsReceived);
  [[connector loadProjectsRequest] send];
}

- (void) loginFailed {
  [self showLoginDialog];
}

- (void) requestFailed {
  kernelPanic = YES;
  PSStopObservingAll();
}

- (void) projectsReceived {
  if ([connector.account userType] == Employee) {
    [self initialDataLoaded];
  } else {
    PSObserve(connector, UsersReceivedNotification, initialDataLoaded);
    [[connector loadUsersRequest] send];
  }
}

- (void) initialDataLoaded {
  PSStopObservingAll();
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
