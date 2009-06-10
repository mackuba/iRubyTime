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

@implementation NSError (RubyTime)

- (NSString *) friendlyDescription {
  if (self.domain == NSURLErrorDomain) {
    switch (self.code) {
      case NSURLErrorBadURL: return @"Incorrect URL.";
      case NSURLErrorTimedOut: return @"Server doesn't respond.";
      case NSURLErrorCannotFindHost: return @"Server not found.";
      case NSURLErrorCannotConnectToHost: return @"Can't connect to the server.";
      case NSURLErrorNetworkConnectionLost: return @"Server disconnected or network connection lost.";
      default: return @"Connection problems.";
    }
  } else if (self.domain == RubyTimeErrorDomain) {
    return @"An error occurred on the server.";
  } else {
    return [self localizedDescription];
  }
}

@end
