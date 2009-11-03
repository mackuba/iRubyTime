// -------------------------------------------------------
// RubyTimeConnector.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "Activity.h"
#import "PathBuilder.h"
#import "Project.h"
#import "Request.h"
#import "RubyTimeConnector.h"
#import "Utils.h"
#import "NSDictionary+BSJSONAdditions.h"

#define ActivityPath(activity) RTFormat(@"/activities/%d", activity.recordId)

// -------------------------------------------------------------------------------------------
#pragma mark Private interface

@interface RubyTimeConnector ()
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

@implementation RubyTimeConnector

@synthesize account;

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
  NSLog(@"sending %@ to %@ (type %d) with '%@'", method, url, type, text);
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

// -------------------------------------------------------------------------------------------
#pragma mark Request sending methods

- (void) authenticate {
  if (account.canLogIn) {
    [self sendGetRequestToPath: @"/users/authenticate" type: RTAuthenticationRequest];
  }
}

- (void) loadActivitiesForUser: (User *) user
                         limit: (NSInteger) limit
                        offset: (NSInteger) offset {
  PathBuilder *builder = [PathBuilder builderWithBasePath: @"/users/%d/activities" record: user];
  [builder setInt: limit forKey: @"limit"];
  [builder setInt: offset forKey: @"offset"];
  [self sendGetRequestToPath: builder.path type: RTActivityIndexRequest];
}

- (void) loadActivitiesForProject: (Project *) project
                            limit: (NSInteger) limit
                           offset: (NSInteger) offset {
  PathBuilder *builder = [PathBuilder builderWithBasePath: @"/projects/%d/activities" record: project];
  [builder setInt: limit forKey: @"limit"];
  [builder setInt: offset forKey: @"offset"];
  [self sendGetRequestToPath: builder.path type: RTActivityIndexRequest];
}

- (void) loadAllActivitiesWithLimit: (NSInteger) limit
                             offset: (NSInteger) offset {
  PathBuilder *builder = [PathBuilder builderWithBasePath: @"/activities"];
  [builder setInt: limit forKey: @"limit"];
  [builder setInt: offset forKey: @"offset"];
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
      [account logInWithResponse: [NSDictionary dictionaryWithJSONString: trimmedString]];
      Notify(AuthenticationSuccessfulNotification);
      break;

    case RTActivityIndexRequest:
      if (trimmedString.length > 0) {
        records = [Activity objectsFromJSONString: trimmedString];
        NotifyWithData(ActivitiesReceivedNotification, RTDict(records, @"activities"));
      }
      break;
    
    case RTProjectIndexRequest:
      if (trimmedString.length > 0) {
        records = [Project objectsFromJSONString: trimmedString];
        [Project appendObjectsToList: records];
        NotifyWithData(ProjectsReceivedNotification, RTDict(records, @"projects"));
      }
      break;

    case RTUserIndexRequest:
      if (trimmedString.length > 0) {
        records = [User objectsFromJSONString: trimmedString];
        [User appendObjectsToList: records];
        if (account.userType == Admin) {
          [User addSelfToTopOfUsers: account];
        }
        NotifyWithData(UsersReceivedNotification, RTDict(records, @"users"));
      }
      break;
    
    case RTCreateActivityRequest:
      activity = [Activity objectFromJSONString: trimmedString];
      NotifyWithData(ActivityCreatedNotification, RTDict(activity, @"activity"));
      break;

    case RTUpdateActivityRequest:
      activity = request.info;
      NotifyWithData(ActivityUpdatedNotification, RTDict(activity, @"activity"));
      break;

    case RTDeleteActivityRequest:
      activity = request.info;
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
