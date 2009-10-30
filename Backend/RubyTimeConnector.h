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
@class Project;
@class Request;
@class User;

@interface RubyTimeConnector : NSObject {
  Request *currentRequest;
  Account *account;
}

@property (nonatomic, retain) Account *account;

- (id) initWithAccount: (Account *) userAccount;
- (void) authenticate;
- (void) loadActivitiesForUser: (User *) user limit: (NSInteger) limit;
- (void) loadActivitiesForProject: (Project *) project limit: (NSInteger) limit;
- (void) loadAllActivitiesWithLimit: (NSInteger) limit;
- (void) loadProjects;
- (void) loadUsers;
- (void) createActivity: (Activity *) activity;
- (void) updateActivity: (Activity *) activity;
- (void) deleteActivity: (Activity *) activity;
- (BOOL) hasOpenConnections;
- (void) dropCurrentConnection;

@end
