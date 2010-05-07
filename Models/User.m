// -------------------------------------------------------
// User.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "User.h"
#import "Utils.h"

@implementation User

@synthesize name;
PSReleaseOnDealloc(name);

+ (NSArray *) propertyList {
  return PSArray(@"name");
}

+ (void) addSelfToTopOfUsers: (User *) user {
  NSMutableArray *userList = (NSMutableArray *) [self list];
  [userList removeObject: user];
  [userList insertObject: user atIndex: 0];
}

@end
