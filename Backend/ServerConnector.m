// -------------------------------------------------------
// ServerConnector.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "Activity.h"
#import "ActivityDateFormatter.h"
#import "Project.h"
#import "ServerConnector.h"
#import "User.h"
#import "Utils.h"

// -------------------------------------------------------------------------------------------
#pragma mark Implementation

@implementation ServerConnector

@synthesize serverApiVersion;

- (id) init {
  self = [super init];
  if (self) {
    self.account = [Account accountFromSettings];
    self.usesHTTPAuthentication = YES;
  }
  return self;
}

- (NSString *) baseURL {
  return [account serverURL];
}

// -------------------------------------------------------------------------------------------
#pragma mark Request sending methods

- (void) prepareRequest: (PSRequest *) request {
  NSString *apiVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"RubyTimeAPIVersion"];

  [request addRequestHeader: @"X-API-Version" value: apiVersion];
  [request addRequestHeader: @"Content-Type" value: @"application/x-www-form-urlencoded"];

  request.useSessionPersistence = NO;
  request.useCookiePersistence = NO;
  request.useKeychainPersistence = NO;
}

- (PSRequest *) authenticateRequest {
  if ([account hasAllRequiredProperties]) {
    PSRequest *request = [self requestToPath: @"/users/authenticate"];
    request.successHandler = @selector(authenticationSucceeded:);
    return request;
  } else {
    return nil;
  }
}

- (PSRequest *) loadActivitiesRequestForUser: (User *) user
                                       limit: (NSInteger) limit
                                      offset: (NSInteger) offset {
  PSRequest *request = [self requestToPath: PSFormat(@"/users/%d/activities", [user toParam])];
  [request addURLParameter: @"search_criteria[limit]" integerValue: limit];
  [request addURLParameter: @"search_criteria[offset]" integerValue: offset];
  [request setSuccessHandler: @selector(activitiesLoaded:)];
  return request;
}

- (PSRequest *) loadActivitiesRequestForProject: (Project *) project
                                          limit: (NSInteger) limit
                                         offset: (NSInteger) offset {
  PSRequest *request = [self requestToPath: PSFormat(@"/projects/%d/activities", [project toParam])];
  [request addURLParameter: @"search_criteria[limit]" integerValue: limit];
  [request addURLParameter: @"search_criteria[offset]" integerValue: offset];
  [request setSuccessHandler: @selector(activitiesLoaded:)];
  return request;
}

- (PSRequest *) loadActivitiesRequestWithLimit: (NSInteger) limit offset: (NSInteger) offset {
  PSRequest *request = [self requestToPath: @"/activities"];
  [request addURLParameter: @"search_criteria[limit]" integerValue: limit];
  [request addURLParameter: @"search_criteria[offset]" integerValue: offset];
  [request setSuccessHandler: @selector(activitiesLoaded:)];
  return request;
}

- (PSRequest *) searchActivitiesRequestWithProject: (Project *) project
                                              user: (User *) user
                                         startDate: (NSDate *) startDate
                                           endDate: (NSDate *) endDate {
  PSRequest *request = [self requestToPath: @"/activities"];

  if (project) {
    [request addURLParameter: @"search_criteria[project_id]" value: project.recordId];
  }
  if (user) {
    [request addURLParameter: @"search_criteria[user_id]" value: user.recordId];
  }

  ActivityDateFormatter *formatter = [ActivityDateFormatter sharedFormatter];
  [request addURLParameter: @"search_criteria[date_from]" value: [formatter formatDateForRequest: startDate]];
  [request addURLParameter: @"search_criteria[date_to]" value: [formatter formatDateForRequest: endDate]];
  [request setSuccessHandler: @selector(activitiesLoaded:)];
  return request;
}

- (PSRequest *) createRequestForActivity: (Activity *) activity {
  PSRequest *request = [self createRequestForObject: activity];
  request.successHandler = @selector(activityCreated:);
  return request;
}

- (PSRequest *) updateRequestForActivity: (Activity *) activity {
  PSRequest *request = [self updateRequestForObject: activity];
  request.successHandler = @selector(activityUpdated:);
  return request;
}

- (PSRequest *) deleteRequestForActivity: (Activity *) activity {
  PSRequest *request = [self deleteRequestForObject: activity];
  request.successHandler = @selector(activityDeleted:);
  return request;
}

- (PSRequest *) loadProjectsRequest {
  PSRequest *request = [self requestToPath: @"/projects?include_activity_types=true"];
  request.successHandler = @selector(projectsLoaded:);
  return request;
}

- (PSRequest *) loadUsersRequest {
  PSRequest *request = [self requestToPath: @"/users/with_activities"];
  request.successHandler = @selector(usersLoaded:);
  return request;
}

// -------------------------------------------------------------------------------------------
#pragma mark Response handling

- (void) authenticationSucceeded: (PSRequest *) request {
  NSDictionary *response = [self parseResponseFromRequest: request];
  if (response) {
    [account logInWithResponse: response];
    PSNotify(AuthenticationSuccessfulNotification);
  }
}

- (void) activitiesLoaded: (PSRequest *) request {
  NSArray *activities = [self parseObjectsFromRequest: request model: [Activity class]];
  if (activities) {
    if ([activities isEqual: PSNull]) {
      activities = [NSArray array];
    }
    PSNotifyWithData(ActivitiesReceivedNotification, PSHash(@"activities", activities));
  }
}

- (void) projectsLoaded: (PSRequest *) request {
  NSArray *projects = [self parseObjectsFromRequest: request model: [Project class]];
  if (projects) {
    [Project reset];
    [Project appendObjectsToList: projects];
    PSNotifyWithData(ProjectsReceivedNotification, PSHash(@"projects", projects));
  }
}

- (void) usersLoaded: (PSRequest *) request {
  NSArray *users = [self parseObjectsFromRequest: request model: [User class]];
  if (users) {
    [User reset];
    [User appendObjectsToList: users];
    if ([account userType] == Admin) {
      [[account asUser] addSelfToTopOfUsers];
    }
    PSNotifyWithData(UsersReceivedNotification, PSHash(@"users", users));
  }
}

- (void) activityCreated: (PSRequest *) request {
  Activity *activity = [self parseObjectFromRequest: request model: [Activity class]];
  if (activity) {
    activity.project.hasActivities = YES;
    PSNotifyWithData(ActivityCreatedNotification, PSHash(@"activity", activity));
  }
}

- (void) activityUpdated: (PSRequest *) request {
  if ([self parseResponseFromRequest: request]) {
    Activity *activity = [request objectForKey: @"object"];
    activity.project.hasActivities = YES;
    PSNotifyWithData(ActivityUpdatedNotification, PSHash(@"activity", activity));
  }
}

- (void) activityDeleted: (PSRequest *) request {
  if ([self parseResponseFromRequest: request]) {
    Activity *activity = [request objectForKey: @"object"];
    PSNotifyWithData(ActivityDeletedNotification, PSHash(@"activity", activity));
  }
}

- (void) handleFailedRequest: (PSRequest *) request {
  PSNotifyWithData(RequestFailedNotification, PSHash(@"request", request));
}

- (void) handleFailedAuthentication: (PSRequest *) request {
  [request cancel];
  [account setPassword: nil]; // make sure that hasAllRequiredProperties returns NO
  PSNotify(AuthenticationFailedNotification);
}

- (void) cleanupRequest: (PSRequest *) request {
  NSString *versionString = [request.responseHeaders objectForKey: @"X-Api-Version"];
  if (versionString) {
    serverApiVersion = [versionString intValue];
  }
  [super cleanupRequest: request];
}

@end
