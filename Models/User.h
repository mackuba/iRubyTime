// -------------------------------------------------------
// User.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface User : NSObject {
  NSString *name;
  NSInteger userId;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger userId;

- (BOOL) isEqual: (id) other;

@end
