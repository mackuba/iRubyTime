// -------------------------------------------------------
// RubyTimeConnector.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

#define AuthenticatingNotification @"AuthenticatingNotification"
#define UpdatingActivitiesNotification @"UpdatingActivitiesNotification"
#define LoadingProjectsNotification @"LoadingProjectsNotification"

#define AuthenticationSuccessfulNotification @"AuthenticationSuccessfulNotification"
#define AuthenticationFailedNotification @"AuthenticationFailedNotification"
#define ActivitiesReceivedNotification @"ActivitiesReceivedNotification"
#define ProjectsReceivedNotification @"ProjectsReceivedNotification"
#define ActivityCreatedNotification @"ActivityCreatedNotification"
#define ActivityUpdatedNotification @"ActivityUpdatedNotification"
#define ActivityDeletedNotification @"ActivityDeletedNotification"
#define RequestFailedNotification @"RequestFailedNotification"

typedef enum {
  Employee = 0,
  ClientUser,
  Admin
} UserType;

@class Activity;
@class DataManager;
@class Request;

@interface RubyTimeConnector : NSObject {
  BOOL loggedIn;
  NSString *serverURL;
  NSString *username;
  NSString *password;
  NSString *authenticationString;
  NSInteger userId;
  UserType userType;
  Request *currentRequest;
  DataManager *dataManager;
}

@property (nonatomic) BOOL loggedIn;
@property (nonatomic, readonly) NSString *serverURL;
@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *password;
@property (nonatomic, retain) NSArray *activities;
@property (nonatomic, retain) NSArray *projects;
@property (nonatomic, readonly) UserType userType;

- (id) init;
- (id) initWithServerURL: (NSString *) url
               username: (NSString *) username
               password: (NSString *) password;

- (void) authenticate;
- (void) updateActivities;
- (void) loadProjects;
- (void) createActivity: (Activity *) activity;
- (void) updateActivity: (Activity *) activity;
- (void) deleteActivity: (Activity *) activity;
- (void) setServerURL: (NSString *) url
             username: (NSString *) aUsername
             password: (NSString *) aPassword;
- (NSArray *) recentProjects;

@end
