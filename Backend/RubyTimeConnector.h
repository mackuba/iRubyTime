// -------------------------------------------------------
// RubyTimeConnector.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

#define AuthenticationSuccessfulNotification @"AuthenticationSuccessfulNotification"
#define AuthenticationFailedNotification @"AuthenticationFailedNotification"
#define ActivitiesReceivedNotification @"ActivitiesReceivedNotification"
#define ProjectsReceivedNotification @"ProjectsReceivedNotification"
#define UsersReceivedNotification @"UsersReceivedNotification"
#define ActivityCreatedNotification @"ActivityCreatedNotification"
#define ActivityUpdatedNotification @"ActivityUpdatedNotification"
#define ActivityDeletedNotification @"ActivityDeletedNotification"
#define RequestFailedNotification @"RequestFailedNotification"

@class Account;
@class Activity;
@class DataManager;
@class Project;
@class Request;
@class User;

@interface RubyTimeConnector : NSObject {
  Request *currentRequest;
  DataManager *dataManager;
  Account *account;
}

@property (nonatomic, readonly) NSArray *projects;
@property (nonatomic, readonly) NSArray *users;
@property (nonatomic, retain) Account *account;

- (id) initWithAccount: (Account *) userAccount;
- (void) authenticate;
- (void) loadActivitiesForUser: (User *) user;
- (void) loadActivitiesForProject: (Project *) project;
- (void) loadProjects;
- (void) loadUsers;
- (void) createActivity: (Activity *) activity;
- (void) updateActivity: (Activity *) activity;
- (void) deleteActivity: (Activity *) activity;
- (BOOL) hasOpenConnections;
- (void) dropCurrentConnection;

@end
