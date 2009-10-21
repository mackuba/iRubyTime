// -------------------------------------------------------
// RubyTimeConnector.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "Activity.h"
#import "DataManager.h"
#import "Request.h"
#import "RubyTimeConnector.h"
#import "Utils.h"
#import "NSDictionary+BSJSONAdditions.h"

#define ServerPath(...) [account.serverURL stringByAppendingFormat: __VA_ARGS__]


// -------------------------------------------------------------------------------------------
#pragma mark Private interface

@interface RubyTimeConnector ()
- (void) handleFinishedRequest: (Request *) request;
- (void) cleanupRequest;
- (void) sendRequest: (Request *) request;
@end


// -------------------------------------------------------------------------------------------
#pragma mark Implementation

@implementation RubyTimeConnector

@synthesize account;

- (id) initWithAccount: (Account *) userAccount {
  if (self = [super init]) {
    dataManager = [[DataManager alloc] init];
    if ([userAccount canLogIn]) {
      [self authenticateWithAccount: userAccount];
    } else {
      [self setAccount: userAccount];
    }
  }
  return self;
}


// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

- (BOOL) hasOpenConnections {
  return currentRequest ? YES : NO;
}

- (NSArray *) activities {
  return dataManager.activities;
}

- (void) setActivities: (NSArray *) activities {
  if (activities) dataManager.activities = activities;
}

- (NSArray *) projects {
  return dataManager.projects;
}

- (void) setProjects: (NSArray *) projects {
  if (projects) dataManager.projects = projects;
}

- (NSArray *) recentProjects {
  return [dataManager valueForKeyPath: @"activities.@distinctUnionOfObjects.project"];
}

- (void) setAccount: (Account *) userAccount {
  [account release];
  account = [userAccount retain];
}

// -------------------------------------------------------------------------------------------
#pragma mark Request sending

- (void) authenticateWithAccount: (Account *) userAccount {
  Notify(AuthenticatingNotification);
  [self setAccount: userAccount];

  Request *request = [[Request alloc] initWithURL: ServerPath(@"/users/authenticate")
                                             type: RTAuthenticationRequest];
  [self sendRequest: request];
}

- (void) updateActivities {
  Notify(UpdatingActivitiesNotification);
  NSString *path = RTFormat(@"/users/%d/activities?search_criteria[limit]=20", account.userId);
  Request *request = [[Request alloc] initWithURL: ServerPath(path) type: RTActivityIndexRequest];
  [self sendRequest: request];
}

- (void) createActivity: (Activity *) activity {
  Request *request = [[Request alloc] initWithURL: ServerPath(@"/activities")
                                           method: @"POST"
                                             text: [activity toQueryString]
                                             type: RTCreateActivityRequest];
  [self sendRequest: request];
}

- (void) updateActivity: (Activity *) activity {
  NSString *contents = [[activity toQueryString] stringByAppendingString: @"&_method=put"];
  Request *request = [[Request alloc] initWithURL: ServerPath(RTFormat(@"/activities/%d", activity.activityId))
                                           method: @"POST"
                                             text: contents
                                             type: RTUpdateActivityRequest];
  request.info = activity;
  [self sendRequest: request];
}

- (void) deleteActivity: (Activity *) activity {
  Request *request = [[Request alloc] initWithURL: ServerPath(RTFormat(@"/activities/%d", activity.activityId))
                                           method: @"POST"
                                             text: @"_method=delete"
                                             type: RTDeleteActivityRequest];
  request.info = activity;
  [self sendRequest: request];
}

- (void) loadProjects {
  Notify(LoadingProjectsNotification);
  Request *request = [[Request alloc] initWithURL: ServerPath(@"/projects") type: RTProjectIndexRequest];
  [self sendRequest: request];
}

- (void) sendRequest: (Request *) request {
  if (currentRequest) {
    [currentRequest.connection cancel];
    [self cleanupRequest];
  }
  currentRequest = request;
  NSLog(@"sending %@ to %@ (type %d) with '%@'", request.HTTPMethod, request.URL, request.type, request.sentText);
  [request setValue: account.authenticationString forHTTPHeaderField: @"Authorization"];
  request.connection = [NSURLConnection connectionWithRequest: request delegate: self];
}

// -------------------------------------------------------------------------------------------
#pragma mark Response handling

- (void) connection: (NSURLConnection *) connection didReceiveResponse: (NSURLResponse *) response {
  currentRequest.response = response;
}

- (void) connection: (NSURLConnection *) connection didReceiveData: (NSData *) data {
  NSString *receivedText = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
  [currentRequest appendReceivedText: receivedText];
  [receivedText release];
}

- (void) connectionDidFinishLoading: (NSURLConnection *) connection {
  Request *request = [[currentRequest retain] autorelease]; // keep it in memory until the end of this method
  [self cleanupRequest];
  
  NSHTTPURLResponse *response = (NSHTTPURLResponse *) request.response;
  NSLog(@"finished request to %@ (%d) (status %d)", request.URL, request.type, response.statusCode);
  NSLog(@"text = \"%@\"", request.receivedText);
  if (response.statusCode >= 400) {
    NSError *error = [NSError errorWithDomain: RubyTimeErrorDomain code: response.statusCode userInfo: nil];
    NotifyWithData(RequestFailedNotification, RTDict(error, @"error", request.receivedText, @"text"));
  } else {
    [self handleFinishedRequest: request];
  }
}

- (void) handleFinishedRequest: (Request *) request {
  NSString *trimmedString = [request.receivedText trimmedString];
  NSArray *records;
  Activity *activity;
  switch (request.type) {
    case RTAuthenticationRequest:
      Notify(AuthenticationSuccessfulNotification);
      [account logInWithResponse: [NSDictionary dictionaryWithJSONString: trimmedString]];
      break;

    case RTActivityIndexRequest:
      if (trimmedString.length > 0) {
        records = [dataManager activitiesFromJSONString: trimmedString];
        dataManager.activities = records;
        NotifyWithData(ActivitiesReceivedNotification, RTDict(records, @"activities"));
      }
      break;
    
    case RTProjectIndexRequest:
      if (trimmedString.length > 0) {
        records = [dataManager projectsFromJSONString: trimmedString];
        dataManager.projects = records;
        NotifyWithData(ProjectsReceivedNotification, RTDict(records, @"projects"));
      }
      break;
    
    case RTCreateActivityRequest:
      activity = [dataManager activityFromJSONString: trimmedString];
      [dataManager addNewActivity: activity];
      NotifyWithData(ActivityCreatedNotification, RTDict(activity, @"activity"));
      break;

    case RTUpdateActivityRequest:
      activity = request.info;
      [dataManager updateActivity: activity];
      NotifyWithData(ActivityUpdatedNotification, RTDict(activity, @"activity"));
      break;

    case RTDeleteActivityRequest:
      activity = request.info;
      [dataManager deleteActivity: activity];
      NotifyWithData(ActivityDeletedNotification, RTDict(activity, @"activity"));
      break;
  }
}

- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error {
  if (error.code != NSURLErrorUserCancelledAuthentication) {
    NotifyWithData(RequestFailedNotification, RTDict(error, @"error", currentRequest, @"request"));
    [self cleanupRequest];
  }
}

- (void) connection: (NSURLConnection *) connection
         didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *) challenge {
  // TODO: let the user try again and reuse the connection
  [[challenge sender] cancelAuthenticationChallenge: challenge];
  [self cleanupRequest];
  account.password = nil; // make sure that canLogIn returns NO
  Notify(AuthenticationFailedNotification);
}

// -------------------------------------------------------------------------------------------
#pragma mark Cleanup

- (void) cleanupRequest {
  [currentRequest release];
  currentRequest = nil;
}

- (void) dealloc {
  [currentRequest.connection cancel];
  [self cleanupRequest];
  [dataManager release];
  [account release];
  [super dealloc];
}

@end
