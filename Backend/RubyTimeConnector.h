#import <Foundation/Foundation.h>

@class Request;

@interface RubyTimeConnector : NSObject {
  __weak id delegate;
  BOOL loggedIn;
  NSString *serverURL;
  NSString *username;
  NSString *password;
  NSString *authenticationString;
  // NSInteger lastMessageId;
  Request *currentRequest;
}

@property (nonatomic) BOOL loggedIn;
@property (nonatomic, retain) id delegate;
@property (nonatomic, readonly) NSString *serverURL;
@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *password;

- (id) init;
- (id) initWithServerURL: (NSString *) url
               username: (NSString *) username
               password: (NSString *) password
               delegate: (id) delegate;

- (void) authenticate;
- (void) getActivities;
// - (void) createActivity: (Activity *) activity;
- (void) setServerURL: (NSString *) url
             username: (NSString *) aUsername
             password: (NSString *) aPassword;

@end
