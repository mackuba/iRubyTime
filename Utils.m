// -------------------------------------------------------
// Utils.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
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

- (NSString *) stringWithPercentEscapesForFormValues {
  CFStringRef escapedSymbols = CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/");
  CFStringRef string = (CFStringRef) [[self mutableCopy] autorelease];
  NSString *escaped =
    (NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, string, NULL, escapedSymbols, kCFStringEncodingUTF8);
  return [escaped autorelease];
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

@implementation UITableView (RubyTime)

- (UITableViewCell *) cellWithStyle: (UITableViewCellStyle) style andIdentifier: (NSString *) identifier {
  UITableViewCell *cell = [self dequeueReusableCellWithIdentifier: identifier];
  if (!cell) {
    cell = [[[UITableViewCell alloc] initWithStyle: style reuseIdentifier: identifier] autorelease];
  }
  return cell;
}

@end

@implementation UIActivityIndicatorView (RubyTime)

+ (UIActivityIndicatorView *) spinnerBarButton {
  UIActivityIndicatorView *spinner =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
  spinner.frame = CGRectMake(0, 0, 36, 20);
  spinner.contentMode = UIViewContentModeCenter;
  return [spinner autorelease];
}

@end

@implementation UIViewController (RubyTime)

- (void) initializeLengthPicker: (UIDatePicker *) picker usingActivity: (Activity *) activity {
  picker.countDownDuration = activity.minutes * 60;
  NSInteger precision = picker.minuteInterval;
  activity.minutes = activity.minutes / precision * precision;
}

@end
