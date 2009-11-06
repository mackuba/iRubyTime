// -------------------------------------------------------
// Utils.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "Utils.h"
#import "SFHFKeychainUtils.h"

#define KEYCHAIN_SERVICE_NAME @"iRubyTime"


// -------------------------------------------------------------------------------------------
#pragma mark IntArray class

@implementation IntArray

@synthesize size;

+ (IntArray *) arrayOfSize: (NSInteger) size integers: (NSInteger) first, ... {
  IntArray *array = [[IntArray alloc] initWithSize: size];
  [array setInteger: first atIndex: 0];
  va_list args;
  va_start(args, first);
  NSInteger next;
  for (NSInteger i = 1; i < size; i++) {
    next = va_arg(args, NSInteger);
    [array setInteger: next atIndex: i];
  }
  va_end(args);
  return [array autorelease];
}

+ (IntArray *) emptyArray {
  return [[[IntArray alloc] initWithSize: 0] autorelease];
}

- (id) initWithSize: (NSInteger) arraySize {
  self = [super init];
  if (self) {
    values = malloc(sizeof(NSInteger) * arraySize);
    size = arraySize;
  }
  return self;
}

- (void) setInteger: (NSInteger) value atIndex: (NSInteger) index {
  values[index] = value;
}

- (NSInteger) integerAtIndex: (NSInteger) index {
  return values[index];
}

@end


// -------------------------------------------------------------------------------------------
#pragma mark Core class extensions

@implementation NSArray (RubyTime)

- (NSDictionary *) groupByKey: (NSString *) key {
  NSMutableDictionary *groups = [[NSMutableDictionary alloc] init];
  for (id object in self) {
    id keyForObject = [object valueForKey: key];
    NSMutableArray *list = [groups objectForKey: keyForObject];
    if (!list) {
      list = [NSMutableArray array];
      [groups setObject: list forKey: keyForObject];
    }
    [list addObject: object];
  }
  return [groups autorelease];
}

@end

@implementation NSDate (RubyTime)

- (NSDate *) midnight {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = @"yyyy-MM-dd";
  NSDate *midnight = [formatter dateFromString: [formatter stringFromDate: self]];
  [formatter release];
  return midnight;
}

- (BOOL) isEarlierThanOrEqualTo: (NSDate *) otherDate {
  NSDate *current = [self midnight];
  NSDate *other = [otherDate midnight];
  return ([current earlierDate: other] == current);
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

- (NSString *) camelizedString {
  NSArray *words = [self componentsSeparatedByString: @"_"];
  if (words.count == 1) {
    return [self copy];
  } else {
    NSMutableString *camelized = [[NSMutableString alloc] initWithString: [words objectAtIndex: 0]];
    for (NSInteger i = 1; i < words.count; i++) {
      [camelized appendString: [[words objectAtIndex: i] capitalizedString]];
    }
    return [camelized autorelease];
  }
}

@end

@implementation NSUserDefaults (RubyTime)

- (NSString *) passwordForKey: (NSString *) key andUsername: (NSString *) username {
  #if TARGET_IPHONE_SIMULATOR
    return [self objectForKey: key];
  #else
    NSString *password = nil;
    NSError *error;
    if (username) {
      password = [SFHFKeychainUtils getPasswordForUsername: username
                                            andServiceName: KEYCHAIN_SERVICE_NAME
                                                     error: &error];
    }
    return password;
  #endif
}

- (void) setPassword: (NSString *) password forKey: (NSString *) key andUsername: (NSString *) username {
  #if TARGET_IPHONE_SIMULATOR
    [self setObject: password forKey: key];
  #else
    NSError *error;
    [SFHFKeychainUtils storeUsername: username
                         andPassword: password
                      forServiceName: KEYCHAIN_SERVICE_NAME
                      updateExisting: YES
                               error: &error];
  #endif
}

@end

@implementation UIAlertView (RubyTime)

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

@implementation UIActivityIndicatorView (RubyTime)

+ (UIActivityIndicatorView *) spinnerBarButton {
  UIActivityIndicatorView *spinner =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
  spinner.frame = CGRectMake(0, 0, 36, 20);
  spinner.contentMode = UIViewContentModeCenter;
  return [spinner autorelease];
}

@end

@implementation UIImage (RubyTime)

+ (UIImage *) loadImageFromBundle: (NSString *) imageName {
  return [UIImage imageNamed: RTFormat(@"Images/%@", imageName)];
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

- (UITableViewCell *) genericCellWithStyle: (UITableViewCellStyle) style {
  return [self cellWithStyle: style andIdentifier: GENERIC_CELL_TYPE];
}

@end

@implementation UIViewController (RubyTime)

- (void) initializeLengthPicker: (UIDatePicker *) picker usingActivity: (Activity *) activity {
  picker.countDownDuration = activity.minutes * 60;
  NSInteger precision = picker.minuteInterval;
  activity.minutes = activity.minutes / precision * precision;
}

- (void) setBackButtonTitle: (NSString *) title {
  UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle: title
                                                             style: UIBarButtonItemStyleDone
                                                            target: nil
                                                            action: nil];
  self.navigationItem.backBarButtonItem = [button autorelease];
}

@end
