// -------------------------------------------------------
// RubyTimeConnector.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "DataManager.h"
#import "Request.h"
#import "RubyTimeConnector.h"
#import "Utils.h"
#import "NSDataMBBase64.h"

#define ServerPath(...) [serverURL stringByAppendingFormat: __VA_ARGS__]

@interface RubyTimeConnector ()
- (NSString *) generateAuthStringFromUsername: (NSString *) username password: (NSString *) password;
- (NSString *) fixURL: (NSString *) url;
- (void) handleFinishedRequest: (Request *) request;
- (void) cleanupRequest;
- (void) sendRequest: (Request *) request;
@end

@implementation RubyTimeConnector

@synthesize serverURL, username, password, loggedIn;

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithServerURL: (NSString *) url
                username: (NSString *) aUsername
                password: (NSString *) aPassword {
  if (self = [super init]) {
    [self setServerURL: url username: aUsername password: aPassword];
    lastActivityId = -1;
    userId = -1;
    loggedIn = NO;
    dataManager = [[DataManager alloc] initWithDelegate: self];
  }
  return self;
}

- (id) init {
  return [self initWithServerURL: nil username: nil password: nil];
}

// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

- (void) setServerURL: (NSString *) url
             username: (NSString *) aUsername
             password: (NSString *) aPassword {
  [username autorelease];
  [password autorelease];
  [serverURL autorelease];
  username = [aUsername copy];
  password = [aPassword copy];
  serverURL = url ? [[self fixURL: url] retain] : nil;
  authenticationString = [[self generateAuthStringFromUsername: username password: password] retain];
}

- (NSString *) generateAuthStringFromUsername: (NSString *) aUsername password: (NSString *) aPassword {
  if (!aUsername || !aPassword) return nil;

  NSString *authString = RTFormat(@"%@:%@", aUsername, aPassword);
  NSData *data = [authString dataUsingEncoding: NSUTF8StringEncoding];
  NSString *encoded = RTFormat(@"Basic %@", [data base64Encoding]);
  return encoded;
}

- (NSString *) fixURL: (NSString *) url {
  url = [[url copy] autorelease];

  if (![url hasPrefix: @"http://"]) {
    url = [@"http://" stringByAppendingString: url];
  }
  if ([url hasSuffix: @"/"]) {
    url = [url substringToIndex: url.length - 1];
  }
  
  return url;
}

- (NSArray *) activities {
  return dataManager.activities;
}

- (NSArray *) projects {
  return dataManager.projects;
}

// -------------------------------------------------------------------------------------------
#pragma mark Request sending

- (void) authenticate {
  Notify(@"authenticate");
  Request *request = [[Request alloc] initWithURL: ServerPath(@"/users/authenticate")
                                             type: RTAuthenticationRequest];
  [self sendRequest: request];
}

- (void) updateActivities {
  Notify(@"updateActivities");
  NSString *path;
  if (lastActivityId == -1) {
    path = RTFormat(@"/users/%d/activities?search_criteria[limit]=20", userId);
  } else {
    path = RTFormat(@"/users/%d/activities?search_criteria[since_activity]=%d", userId, lastActivityId);
  }
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

- (void) loadProjects {
  Notify(@"loadProjects");
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
  [request setValue: authenticationString forHTTPHeaderField: @"Authorization"];
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
  NSLog(@"finished request to %@ (%d) (status %d, text = %@)",
    request.URL, request.type, response.statusCode, request.receivedText);
  if (response.statusCode >= 400) {
    NotifyWithData(@"requestFailed", RTDict(RTInt(response.statusCode), @"errorCode"));
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
      Notify(@"authenticationSuccessful");
      loggedIn = YES;
      userId = [trimmedString intValue];
      break;
    
    case RTActivityIndexRequest:
      if (trimmedString.length > 0) {
        records = [dataManager activitiesFromJSONString: trimmedString];
        if (records.count > 0) {
          lastActivityId = [[records objectAtIndex: 0] activityId];
        }
        [dataManager addActivities: records];
      }
      break;
    
    case RTProjectIndexRequest:
      trimmedString = [request.receivedText trimmedString];
      if (trimmedString.length > 0) {
        records = [dataManager projectsFromJSONString: trimmedString];
        [dataManager setProjects: records];
      }
      break;
    
    case RTCreateActivityRequest:
      activity = [dataManager activityFromJSONString: trimmedString];
      [dataManager addNewActivity: activity];
      NotifyWithData(@"activityCreated", RTDict(activity, @"activity"));
      break;
  }
}

- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error {
  if (error.code != NSURLErrorUserCancelledAuthentication) {
    NotifyWithData(@"requestFailed", RTDict(error, @"error"));
    [self cleanupRequest];
  }
}

- (void) connection: (NSURLConnection *) connection
         didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *) challenge {
  Notify(@"authenticationFailed");
  // TODO: let the user try again and reuse the connection
  [[challenge sender] cancelAuthenticationChallenge: challenge];
  [self cleanupRequest];
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
  dataManager.delegate = nil;
  ReleaseAll(serverURL, username, password, authenticationString, dataManager);
  [super dealloc];
}

@end
