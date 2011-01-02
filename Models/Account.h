// -------------------------------------------------------
// Account.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

typedef enum { Employee, ClientUser, Admin } UserType;

@class User;

@interface Account : PSAccount {}

@property (nonatomic) BOOL loggedIn;
@property (nonatomic, readonly) UserType userType;
@property (nonatomic, copy) NSString *userTypeString;
@property (nonatomic, copy) NSString *serverURL;
@property (nonatomic, copy) NSString *name;

- (void) logInWithResponse: (NSDictionary *) dictionary;
- (User *) asUser;

@end
