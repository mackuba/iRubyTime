#import "NSDataMBBase64.h"
#import "Constants.h"
#import "RubyTimeConnector.h"
#import "Request.h"
#import "Utils.h"
#import "Activity.h"

#define ServerPath(...) [serverURL stringByAppendingFormat: __VA_ARGS__]

#define SafeDelegateCall(method, ...) \
  if ([delegate respondsToSelector: @selector(method)]) [delegate method __VA_ARGS__]


@interface NSObject (RubyTimeConnectorDelegate)
//- activityCreated;
- activitiesReceived: (NSArray *) activities;
- authenticationSuccessful;
- authenticationFailed;
- requestFailedWithError: (NSError *) error;
@end

@interface RubyTimeConnector ()
- (NSString *) generateAuthenticationStringFromUsername: (NSString *) username
                                               password: (NSString *) password;
- (void) handleFinishedRequest;
- (void) cleanupRequest;
- (void) sendRequest: (Request *) request;
@end


@implementation RubyTimeConnector

@synthesize serverURL, username, password, delegate, loggedIn;

// -------------------------------------------------------------------------------------------
#pragma mark Initializers

- (id) initWithServerURL: (NSString *) url
                username: (NSString *) aUsername
                password: (NSString *) aPassword
                delegate: (id) aDelegate {
  if (self = [super init]) {
    [self setServerURL: url username: aUsername password: aPassword];
    delegate = aDelegate;
    // lastMessageId = -1;
    loggedIn = NO;
  }
  return self;
}

- (id) init {
  return [self initWithServerURL: nil username: nil password: nil delegate: nil];
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
  serverURL = [url copy];
  // TODO: add http:// if not present, remove trailing slash, etc.
  authenticationString = [self generateAuthenticationStringFromUsername: username
                                                               password: password];
  [authenticationString retain];
}

- (NSString *) generateAuthenticationStringFromUsername: (NSString *) aUsername
                                               password: (NSString *) aPassword {
  if (aUsername && aPassword) {
    NSString *authString = RTFormat(@"%@:%@", aUsername, aPassword);
    NSData *data = [authString dataUsingEncoding: NSUTF8StringEncoding];
    NSString *encoded = RTFormat(@"Basic %@", [data base64Encoding]);
    return encoded;
  } else {
    return nil;
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Request sending

- (void) authenticate {
  // TODO: how to check login in RubyTime?
  Request *request = [[Request alloc] initWithURL: ServerPath(@"/login") type: RTAuthenticationRequest];
  [self sendRequest: request];
}

- (void) getActivities {
  Request *request = [[Request alloc] initWithURL: ServerPath(@"/activities.json") type: RTActivityIndexRequest];
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
  NSLog(@"finished request to %@ (%d) (text = %@)", currentRequest.URL, currentRequest.type, currentRequest.receivedText);
  [self handleFinishedRequest];
  [self cleanupRequest];
}

- (void) handleFinishedRequest {
  NSString *trimmedString;
  NSArray *activities;
  switch (currentRequest.type) {
    case RTAuthenticationRequest:
      SafeDelegateCall(authenticationSuccessful);
      loggedIn = YES;
      break;
    
    case RTActivityIndexRequest:
      trimmedString = [currentRequest.receivedText trimmedString];
      if (trimmedString.length > 0) {
        activities = [Activity activitiesFromJSONString: trimmedString];
        // if (activities.count > 0) {
        //   lastMessageId = [[messages objectAtIndex: 0] messageId];
        // }
        SafeDelegateCall(activitiesReceived:, activities);
      }
      break;
  }
}

- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error {
  SafeDelegateCall(requestFailedWithError:, error);
  [self cleanupRequest];
}

- (void) connection: (NSURLConnection *) connection
         didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *) challenge {
  SafeDelegateCall(authenticationFailed);
  // TODO: let the user try again and reuse the connection
  [[challenge sender] cancelAuthenticationChallenge: challenge];
  [self cleanupRequest];
}

// -------------------------------------------------------------------------------------------
#pragma mark Cleaning up

- (void) cleanupRequest {
  [currentRequest release];
  currentRequest = nil;
}

- (void) dealloc {
  [currentRequest.connection cancel];
  [self cleanupRequest];
  ReleaseAll(serverURL, username, password, authenticationString);
  [super dealloc];
}

@end
