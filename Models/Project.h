// -------------------------------------------------------
// Project.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Model.h"

@interface Project : Model {
  NSString *name;
}

@property (nonatomic, copy) NSString *name;

@end
