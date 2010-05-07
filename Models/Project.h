// -------------------------------------------------------
// Project.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

@interface Project : PSModel {
  NSString *name;
  BOOL hasActivities;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic) BOOL hasActivities;

+ (NSArray *) allWithActivities;

@end
