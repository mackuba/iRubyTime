// -------------------------------------------------------
// ServerConnector.h
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
@class User;

@interface ServerConnector : PSConnector {
  NSInteger serverApiVersion;
}

@property (nonatomic, readonly) NSInteger serverApiVersion;

- (PSRequest *) authenticateRequest;
- (PSRequest *) loadActivitiesRequestForUser: (User *) user
                                       limit: (NSInteger) limit
                                      offset: (NSInteger) offset;
- (PSRequest *) loadActivitiesRequestForProject: (Project *) project
                                          limit: (NSInteger) limit
                                         offset: (NSInteger) offset;
- (PSRequest *) loadActivitiesRequestWithLimit: (NSInteger) limit offset: (NSInteger) offset;
- (PSRequest *) searchActivitiesRequestWithProject: (Project *) project
                                              user: (User *) user
                                         startDate: (NSDate *) startDate
                                           endDate: (NSDate *) endDate;
- (PSRequest *) createRequestForActivity: (Activity *) activity;
- (PSRequest *) updateRequestForActivity: (Activity *) activity;
- (PSRequest *) deleteRequestForActivity: (Activity *) activity;
- (PSRequest *) loadProjectsRequest;
- (PSRequest *) loadUsersRequest;

@end
