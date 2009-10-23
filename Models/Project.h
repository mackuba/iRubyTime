// -------------------------------------------------------
// Project.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface Project : NSObject {
  NSString *name;
  NSInteger projectId;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger projectId;

- (BOOL) isEqual: (id) other;

@end
