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
- (UserType) userTypeFromString: (NSString *) typeString;
@end


// -------------------------------------------------------------------------------------------
#pragma mark Implementation

@implementation Account

@synthesize serverURL, username, password, loggedIn, userType, userId, authenticationString;
OnDeallocRelease(serverURL, username, password, authenticationString);

- (id) initWithServerURL: (NSString *) url
                username: (NSString *) name
                password: (NSString *) pass {
  if (self = [super init]) {
    userId = -1;
    loggedIn = NO;
    username = [name copy];
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

- (UserType) userTypeFromString: (NSString *) typeString {
  if ([typeString isEqualToString: @"client"]) {
    return ClientUser;
  } else if ([typeString isEqualToString: @"admin"]) {
    return Admin;
  } else {
    return Employee;
  }
}

- (void) logInWithResponse: (NSDictionary *) dictionary {
  loggedIn = YES;
  userId = [[dictionary objectForKey: @"id"] intValue];
  userType = [self userTypeFromString: [dictionary objectForKey: @"type"]];
}

@end
