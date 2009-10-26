// -------------------------------------------------------
// Account.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>
#import "User.h"

typedef enum { Employee, ClientUser, Admin } UserType;

@interface Account : User {
  BOOL loggedIn;
  NSString *serverURL;
  NSString *username;
  NSString *password;
  NSString *authenticationString;
  UserType userType;
}

@property (nonatomic) BOOL loggedIn;
@property (nonatomic, readonly) UserType userType;
@property (nonatomic, readonly) NSString *serverURL;
@property (nonatomic, readonly) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, readonly) NSString *authenticationString;

- (id) initWithServerURL: (NSString *) url
                username: (NSString *) name
                password: (NSString *) pass;

- (BOOL) canLogIn;
- (void) logInWithResponse: (NSDictionary *) dictionary;
- (void) setUserTypeFromString: (NSString *) typeString;
- (NSString *) userTypeToString;

@end
