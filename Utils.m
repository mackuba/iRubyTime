// -------------------------------------------------------
// Utils.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "Utils.h"

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
  } else if (self.domain == PsiToolkitErrorDomain && self.code > 0) {
    switch (self.code) {
      case 403: return @"Access denied - please contact your administrator.";
      case 412: return @"This version of iRubyTime is not compatible with your RubyTime server. "
                       @"Please check if there are any updates in the AppStore or contact your server administrator.";
      default: return @"An error occurred on the server.";
    }
  } else {
    return [self localizedDescription];
  }
}

@end

@implementation UIActivityIndicatorView (RubyTime)

+ (UIActivityIndicatorView *) spinnerBarButton {
  UIActivityIndicatorView *spinner;
  if (PSiPadDevice) {
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
  } else {
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
  }
  spinner.frame = CGRectMake(0, 0, 36, 20);
  spinner.contentMode = UIViewContentModeCenter;
  return [spinner autorelease];
}

@end

@implementation UIImage (RubyTime)

+ (UIImage *) loadImageFromBundle: (NSString *) imageName {
  return [UIImage imageNamed: PSFormat(@"Images/%@", imageName)];
}

@end

@implementation UIViewController (RubyTime)

- (void) initializeLengthPicker: (UIDatePicker *) picker usingActivity: (Activity *) activity {
  picker.countDownDuration = activity.minutes * 60;
  NSInteger precision = picker.minuteInterval;
  activity.minutes = activity.minutes / precision * precision;
}

@end
