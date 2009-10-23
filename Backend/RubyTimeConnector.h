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
#define ActivityCreatedNotification @"ActivityCreatedNotification"
#define ActivityUpdatedNotification @"ActivityUpdatedNotification"
#define ActivityDeletedNotification @"ActivityDeletedNotification"
#define RequestFailedNotification @"RequestFailedNotification"

@class Account;
@class Activity;
@class DataManager;
@class Request;

@interface RubyTimeConnector : NSObject {
  Request *currentRequest;
  DataManager *dataManager;
  Account *account;
}

@property (nonatomic, retain) NSArray *projects;
@property (nonatomic, retain) Account *account;

- (id) initWithAccount: (Account *) userAccount;
- (void) authenticate;
- (void) loadActivities;
- (void) loadProjects;
- (void) createActivity: (Activity *) activity;
- (void) updateActivity: (Activity *) activity;
- (void) deleteActivity: (Activity *) activity;
- (BOOL) hasOpenConnections;

@end
