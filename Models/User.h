// -------------------------------------------------------
// User.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

@interface User : PSModel {}

@property (nonatomic, copy) NSString *name;

- (void) addSelfToTopOfUsers;

@end
