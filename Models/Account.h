// -------------------------------------------------------
// Account.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "User.h"

typedef enum { Employee, ClientUser, Admin } UserType;

@interface Account : User {}

@property (nonatomic) BOOL loggedIn;
@property (nonatomic, readonly) UserType userType;
@property (nonatomic, readonly) NSString *serverURL;
@property (nonatomic, readonly) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, readonly) NSString *authenticationString;
@property (nonatomic, copy) NSString *userTypeString;

- (id) initWithServerURL: (NSString *) url
                username: (NSString *) name
                password: (NSString *) pass;

- (BOOL) canLogIn;
- (void) logInWithResponse: (NSDictionary *) dictionary;

@end
