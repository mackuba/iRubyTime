// -------------------------------------------------------
// Utils.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Utils.h"

@implementation Utils

+ (void) showAlertWithTitle: (NSString *) title content: (NSString *) content {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
                                                  message: content
                                                 delegate: nil
                                        cancelButtonTitle: @"OK"
                                        otherButtonTitles: nil];
  [alert show];
  [alert release];
}

@end

@implementation NSString (RubyTime)

- (NSString *) trimmedString {
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  return [self stringByTrimmingCharactersInSet: whitespace];
}

@end
