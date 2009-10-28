// -------------------------------------------------------
// Project.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Project.h"
#import "Utils.h"

@implementation Project

SynthesizeAndReleaseLater(name);

- (id) init {
  return [super initWithModelName: @"Project" properties: RTArray(@"name")];
}

@end
