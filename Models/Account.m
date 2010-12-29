// -------------------------------------------------------
// Account.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "Utils.h"
#import "NSDataMBBase64.h"

// -------------------------------------------------------------------------------------------
#pragma mark Private interface

@interface Account ()
- (NSString *) fixURL: (NSString *) url;
- (void) generateAuthenticationString;
@end


// -------------------------------------------------------------------------------------------
#pragma mark Implementation

@implementation Account

@synthesize serverURL, username, password, loggedIn, userType, authenticationString;
PSReleaseOnDealloc(serverURL, username, password, authenticationString);

- (id) initWithServerURL: (NSString *) url
                username: (NSString *) user
                password: (NSString *) pass {
  if (self = [super init]) {
    recordId = [PSInt(-1) retain];
    loggedIn = NO;
    username = [user copy];
    password = [pass copy];
    serverURL = [[self fixURL: url] retain];
    [self generateAuthenticationString];
  }
  return self;
}

- (BOOL) canLogIn {
  return (username && password && serverURL);
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

- (void) generateAuthenticationString {
  if (username && password) {
    NSString *stringToEncode = PSFormat(@"%@:%@", username, password);
    NSData *data = [stringToEncode dataUsingEncoding: NSUTF8StringEncoding];
    NSString *encoded = PSFormat(@"Basic %@", [data base64Encoding]);
    authenticationString = [encoded retain];
  }
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

@end
