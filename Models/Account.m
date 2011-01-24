// -------------------------------------------------------
// Account.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "User.h"
#import "Utils.h"

// -------------------------------------------------------------------------------------------
#pragma mark Private interface

@interface Account ()
- (NSString *) fixURL: (NSString *) url;
@end

// -------------------------------------------------------------------------------------------
#pragma mark Implementation

@implementation Account

@synthesize loggedIn, userType;
PSModelProperties(serverURL, name, userTypeString);
PSReleaseOnDealloc(serverURL, name);

+ (NSArray *) propertiesSavedInSettings {
  return PSArray(@"username", @"password", @"serverURL", @"userTypeString");
}

+ (BOOL) isPropertySavedSecurely: (NSString *) property {
  return ([property isEqual: @"password"]);
}

- (id) init {
  self = [super init];
  if (self) {
    self.loggedIn = NO;
  }
  return self;
}

- (void) setServerURL: (NSString *) url {
  if (url != serverURL) {
    [serverURL release];
    serverURL = [[self fixURL: url] retain];
  }
}

- (NSString *) fixURL: (NSString *) url {
  if (url) {
    url = [[url copy] autorelease];

    if (![url hasPrefix: @"http://"]) {
      url = [@"http://" stringByAppendingString: url];
    }
    if ([url hasSuffix: @"/"]) {
      url = [url substringToIndex: url.length - 1];
    }
  }
  return url;
}

- (void) setUserTypeString: (NSString *) typeString {
  if ([typeString isEqualToString: @"client_user"]) {
    userType = ClientUser;
  } else if ([typeString isEqualToString: @"admin"]) {
    userType = Admin;
  } else {
    userType = Employee;
  }
}

- (NSString *) userTypeString {
  switch (userType) {
    case Employee: return @"employee";
    case Admin: return @"admin";
    case ClientUser: return @"client_user";
    default: return @"";
  }
}

- (void) logInWithResponse: (NSDictionary *) dictionary {
  loggedIn = YES;
  self.recordId = [dictionary objectForKey: @"id"];
  self.name = [dictionary objectForKey: @"name"];
  self.userTypeString = [dictionary objectForKey: @"user_type"];
}

- (User *) asUser {
  User *user = [[User alloc] init];
  user.name = name;
  user.recordId = self.recordId;
  return [user autorelease];
}

@end
