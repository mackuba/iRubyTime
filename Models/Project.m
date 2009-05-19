// -------------------------------------------------------
// Project.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Project.h"
#import "Utils.h"

@implementation Project

@synthesize projectId;
SynthesizeAndReleaseLater(name);

- (void) encodeWithCoder: (NSCoder *) coder {
  [coder encodeObject: name forKey: @"name"];
  [coder encodeInt: projectId forKey: @"projectId"];
}

- (id) initWithCoder: (NSCoder *) coder {
  self = [super init];
  self.name = [coder decodeObjectForKey: @"name"];
  projectId = [coder decodeIntForKey: @"projectId"];
  return self;
}

@end
