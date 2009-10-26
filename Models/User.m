// -------------------------------------------------------
// User.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "User.h"
#import "Utils.h"

@implementation User

@synthesize userId;
SynthesizeAndReleaseLater(name);

- (id) copyWithZone: (NSZone *) zone {
  User *other = [[User alloc] init];
  other.name = self.name;
  other.userId = self.userId;
  return other;
}

- (BOOL) isEqual: (id) other {
  if ([other isKindOfClass: [User class]]) {
    User *otherUser = (User *) other;
    return otherUser.userId == self.userId;
  } else {
    return false;
  }
}

- (NSUInteger) hash {
  return userId;
}

@end
