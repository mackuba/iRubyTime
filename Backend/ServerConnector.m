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
#import "Request.h"
#import "ServerConnector.h"
#import "Utils.h"

#define ActivityPath(activity) PSFormat(@"/activities/%@", activity.recordId)

// -------------------------------------------------------------------------------------------
#pragma mark Private interface

@interface ServerConnector ()
- (void) handleFinishedRequest: (Request *) request;
- (void) cleanupRequest;
- (void) sendPostRequestToPath: (NSString *) path type: (RTRequestType) type text: (NSString *) text;
- (void) sendGetRequestToPath: (NSString *) path type: (RTRequestType) type text: (NSString *) text;
- (void) sendGetRequestToPath: (NSString *) path type: (RTRequestType) type;
- (void) sendRequestToPath: (NSString *) path
                    method: (NSString *) method
                      type: (RTRequestType) type
                      text: (NSString *) text
                      info: (id) info;
@end


// -------------------------------------------------------------------------------------------
#pragma mark Implementation

@implementation ServerConnector

@synthesize account, serverApiVersion;

- (id) initWithAccount: (Account *) userAccount {
  if (self = [super init]) {
    self.account = userAccount;
  }
  return self;
}


// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

- (BOOL) hasOpenConnections {
  return currentRequest ? YES : NO;
}

// -------------------------------------------------------------------------------------------
#pragma mark General request sending helpers

- (void) sendRequestToPath: (NSString *) path
                    method: (NSString *) method
                      type: (RTRequestType) type
                      text: (NSString *) text
                      info: (id) info {
  if (currentRequest) {
    [currentRequest.connection cancel];
    [self cleanupRequest];
  }
  NSString *url = [account.serverURL stringByAppendingString: path];
  currentRequest = [[Request alloc] initWithURL: url method: method type: type text: text];
  if (info) {
    currentRequest.info = info;
  }
  PSLog(@"sending %@ to %@ (type %d) with '%@'", method, url, type, text);
  [currentRequest setValue: account.authenticationString forHTTPHeaderField: @"Authorization"];
  currentRequest.connection = [NSURLConnection connectionWithRequest: currentRequest delegate: self];
}

- (void) sendPostRequestToPath: (NSString *) path type: (RTRequestType) type text: (NSString *) text {
  [self sendRequestToPath: path method: @"POST" type: type text: text info: nil];
}

- (void) sendGetRequestToPath: (NSString *) path type: (RTRequestType) type text: (NSString *) text {
  [self sendRequestToPath: path method: @"GET" type: type text: text info: nil];
}

- (void) sendGetRequestToPath: (NSString *) path type: (RTRequestType) type {
  [self sendRequestToPath: path method: @"GET" type: type text: nil info: nil];
}

- (void) clearCookies {
  NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
  NSArray *cookies = [cookieStorage cookiesForURL: [NSURL URLWithString: account.serverURL]];
  for (NSHTTPCookie *cookie in cookies) {
    [cookieStorage deleteCookie: cookie];
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Request sending methods

- (void) authenticate {
  if (account.canLogIn) {
    [self clearCookies];
    [self sendGetRequestToPath: @"/users/authenticate" type: RTAuthenticationRequest];
  }
}

- (void) loadActivitiesForUser: (User *) user
                         limit: (NSInteger) limit
                        offset: (NSInteger) offset {
  PSPathBuilder *builder = [PSPathBuilder builderWithBasePath: @"/users/%d/activities" record: user];
  [builder setInt: limit forKey: @"search_criteria[limit]"];
  [builder setInt: offset forKey: @"search_criteria[offset]"];
  [self sendGetRequestToPath: builder.path type: RTActivityIndexRequest];
}

- (void) loadActivitiesForProject: (Project *) project
                            limit: (NSInteger) limit
                           offset: (NSInteger) offset {
  PSPathBuilder *builder = [PSPathBuilder builderWithBasePath: @"/projects/%d/activities" record: project];
  [builder setInt: limit forKey: @"search_criteria[limit]"];
  [builder setInt: offset forKey: @"search_criteria[offset]"];
  [self sendGetRequestToPath: builder.path type: RTActivityIndexRequest];
}

- (void) loadAllActivitiesWithLimit: (NSInteger) limit
                             offset: (NSInteger) offset {
  PSPathBuilder *builder = [PSPathBuilder builderWithBasePath: @"/activities"];
  [builder setInt: limit forKey: @"search_criteria[limit]"];
  [builder setInt: offset forKey: @"search_criteria[offset]"];
  [self sendGetRequestToPath: builder.path type: RTActivityIndexRequest];
}

- (void) searchActivitiesForProject: (Project *) project
                               user: (User *) user
                          startDate: (NSDate *) startDate
                            endDate: (NSDate *) endDate {
  PSPathBuilder *builder = [PSPathBuilder builderWithBasePath: @"/activities"];
  if (project) {
    [builder setObject: project.recordId forKey: @"search_criteria[project_id]"];
  }
  if (user) {
    [builder setObject: user.recordId forKey: @"search_criteria[user_id]"];
  }
  ActivityDateFormatter *formatter = [ActivityDateFormatter sharedFormatter];
  [builder setObject: [formatter formatDateForRequest: startDate] forKey: @"search_criteria[date_from]"];
  [builder setObject: [formatter formatDateForRequest: endDate] forKey: @"search_criteria[date_to]"];
  [self sendGetRequestToPath: builder.path type: RTActivityIndexRequest];
}

- (void) createActivity: (Activity *) activity {
  [self sendPostRequestToPath: @"/activities" type: RTCreateActivityRequest text: [activity toQueryString]];
}

- (void) updateActivity: (Activity *) activity {
  [self sendRequestToPath: ActivityPath(activity)
                   method: @"PUT"
                     type: RTUpdateActivityRequest
                     text: [activity toQueryString]
                     info: activity];
}

- (void) deleteActivity: (Activity *) activity {
  [self sendRequestToPath: ActivityPath(activity)
                   method: @"DELETE"
                     type: RTDeleteActivityRequest
                     text: nil
                     info: activity];
}

- (void) loadProjects {
  [self sendGetRequestToPath: @"/projects" type: RTProjectIndexRequest];
}

- (void) loadUsers {
  [self sendGetRequestToPath: @"/users/with_activities" type: RTUserIndexRequest];
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
  PSLog(@"finished request to %@ (%d) (status %d)", request.URL, request.type, response.statusCode);
  PSLog(@"text = \"%@\"", request.receivedText);
  NSString *versionString = [response.allHeaderFields objectForKey: @"X-Api-Version"];
  serverApiVersion = versionString ? [versionString intValue] : -1;

  if (response.statusCode >= 400) {
    NSError *error = [NSError errorWithDomain: RubyTimeErrorDomain code: response.statusCode userInfo: nil];
    PSNotifyWithData(RequestFailedNotification, PSDict(error, @"error", request.receivedText, @"text"));
  } else {
    [self handleFinishedRequest: request];
  }
}

- (void) handleFinishedRequest: (Request *) request {
  NSString *trimmedString = [request.receivedText psTrimmedString];
  NSArray *records;
  Activity *activity;
  switch (request.type) {
    case RTAuthenticationRequest:
      [account logInWithResponse: [trimmedString yajl_JSON]];
      PSNotify(AuthenticationSuccessfulNotification);
      break;

    case RTActivityIndexRequest:
      if (trimmedString.length > 0) {
        records = [Activity objectsFromJSONString: trimmedString];
        PSNotifyWithData(ActivitiesReceivedNotification, PSDict(records, @"activities"));
      }
      break;
    
    case RTProjectIndexRequest:
      if (trimmedString.length > 0) {
        records = [Project objectsFromJSONString: trimmedString];
        [Project reset];
        [Project appendObjectsToList: records];
        PSNotifyWithData(ProjectsReceivedNotification, PSDict(records, @"projects"));
      }
      break;

    case RTUserIndexRequest:
      if (trimmedString.length > 0) {
        records = [User objectsFromJSONString: trimmedString];
        [User reset];
        [User appendObjectsToList: records];
        if (account.userType == Admin) {
          [User addSelfToTopOfUsers: account];
        }
        PSNotifyWithData(UsersReceivedNotification, PSDict(records, @"users"));
      }
      break;
    
    case RTCreateActivityRequest:
      activity = [Activity objectFromJSONString: trimmedString];
      activity.project.hasActivities = YES;
      PSNotifyWithData(ActivityCreatedNotification, PSDict(activity, @"activity"));
      break;

    case RTUpdateActivityRequest:
      activity = request.info;
      activity.project.hasActivities = YES;
      PSNotifyWithData(ActivityUpdatedNotification, PSDict(activity, @"activity"));
      break;

    case RTDeleteActivityRequest:
      activity = request.info;
      PSNotifyWithData(ActivityDeletedNotification, PSDict(activity, @"activity"));
      break;
  }
}

- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error {
  if (error.code != NSURLErrorUserCancelledAuthentication) {
    PSNotifyWithData(RequestFailedNotification, PSDict(error, @"error", currentRequest, @"request"));
    [self cleanupRequest];
  }
}

- (void) connection: (NSURLConnection *) connection
         didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *) challenge {
  // TODO: let the user try again and reuse the connection
  [[challenge sender] cancelAuthenticationChallenge: challenge];
  [self cleanupRequest];
  account.password = nil; // make sure that canLogIn returns NO
  PSNotify(AuthenticationFailedNotification);
}

// -------------------------------------------------------------------------------------------
#pragma mark Cleanup

- (void) cleanupRequest {
  [currentRequest release];
  currentRequest = nil;
}

- (void) dropCurrentConnection {
  [currentRequest.connection cancel];
  [self cleanupRequest];
}

- (void) dealloc {
  [self dropCurrentConnection];
  [account release];
  [super dealloc];
}

@end
