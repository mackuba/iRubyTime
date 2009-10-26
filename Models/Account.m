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
OnDeallocRelease(serverURL, username, password, authenticationString);

- (id) initWithServerURL: (NSString *) url
                username: (NSString *) user
                password: (NSString *) pass {
  if (self = [super init]) {
    userId = -1;
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
    NSString *stringToEncode = RTFormat(@"%@:%@", username, password);
    NSData *data = [stringToEncode dataUsingEncoding: NSUTF8StringEncoding];
    NSString *encoded = RTFormat(@"Basic %@", [data base64Encoding]);
    authenticationString = [encoded retain];
  }
}

- (void) setUserTypeFromString: (NSString *) typeString {
  if ([typeString isEqualToString: @"client"]) {
    userType = ClientUser;
  } else if ([typeString isEqualToString: @"admin"]) {
    userType = Admin;
  } else {
    userType = Employee;
  }
}

- (NSString *) userTypeToString {
  switch (userType) {
    case Employee: return @"employee";
    case Admin: return @"admin";
    case ClientUser: return @"client";
    default: return @"";
  }
}

- (void) logInWithResponse: (NSDictionary *) dictionary {
  loggedIn = YES;
  userId = [[dictionary objectForKey: @"id"] intValue];
  [self setUserTypeFromString: [dictionary objectForKey: @"type"]];
}

@end
