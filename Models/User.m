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

- (id) init {
  return [super initWithModelName: @"User" properties: PSArray(@"name")];
}

+ (void) addSelfToTopOfUsers: (User *) user {
  NSMutableArray *userList = [self list];
  [userList removeObject: user];
  [userList insertObject: user atIndex: 0];
}

@end
