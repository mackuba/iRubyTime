// -------------------------------------------------------
// RubyTimeConnector.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class Request;
@class DataManager;

@interface RubyTimeConnector : NSObject {
  BOOL loggedIn;
  NSString *serverURL;
  NSString *username;
  NSString *password;
  NSString *authenticationString;
  NSInteger lastActivityId;
  Request *currentRequest;
  DataManager *dataManager;
}

@property (nonatomic) BOOL loggedIn;
@property (nonatomic, readonly) NSString *serverURL;
@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *password;
@property (nonatomic, readonly) NSArray *activities;

- (id) init;
- (id) initWithServerURL: (NSString *) url
               username: (NSString *) username
               password: (NSString *) password;

- (void) authenticate;
- (void) updateActivities;
- (void) loadProjects;
// - (void) createActivity: (Activity *) activity;
- (void) setServerURL: (NSString *) url
             username: (NSString *) aUsername
             password: (NSString *) aPassword;

@end
