// -------------------------------------------------------
// RubyTimeConnector.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class Activity;
@class DataManager;
@class Request;

@interface RubyTimeConnector : NSObject {
  BOOL loggedIn;
  NSString *serverURL;
  NSString *username;
  NSString *password;
  NSString *authenticationString;
  NSInteger lastActivityId;
  NSInteger userId;
  Request *currentRequest;
  DataManager *dataManager;
}

@property (nonatomic) BOOL loggedIn;
@property (nonatomic, readonly) NSString *serverURL;
@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *password;
@property (nonatomic, retain) NSArray *activities;
@property (nonatomic, retain) NSArray *projects;

- (id) init;
- (id) initWithServerURL: (NSString *) url
               username: (NSString *) username
               password: (NSString *) password;

- (void) authenticate;
- (void) updateActivities;
- (void) loadProjects;
- (void) createActivity: (Activity *) activity;
- (void) setServerURL: (NSString *) url
             username: (NSString *) aUsername
             password: (NSString *) aPassword;
- (NSArray *) recentProjects;

@end
