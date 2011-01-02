// -------------------------------------------------------
// PSFoundationExtensions.m
//
// Copyright (c) 2010-11 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "PSFoundationExtensions.h"
#import "PSMacros.h"

// ------------------------------------------------------------------------------------------------

@implementation NSArray (PsiToolkit)

- (NSArray *) psCompact {
  static NSPredicate *notNullPredicate = nil;
  if (!notNullPredicate) {
    notNullPredicate = [[NSPredicate predicateWithFormat: @"SELF != NIL"] retain];
  }
  return [self filteredArrayUsingPredicate: notNullPredicate];
}

- (NSArray *) psSortedArrayUsingField: (NSString *) field ascending: (BOOL) ascending {
  NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey: field
                                                             ascending: ascending
                                                              selector: @selector(caseInsensitiveCompare:)];
  NSArray *descriptors = [[NSArray alloc] initWithObjects: descriptor, nil];
  NSArray *sortedArray = [self sortedArrayUsingDescriptors: descriptors];
  [descriptor release];
  [descriptors release];
  return sortedArray;
}

- (NSDictionary *) psGroupByKey: (NSString *) key {
  NSMutableDictionary *groups = [[NSMutableDictionary alloc] init];
  for (id object in self) {
    id keyForObject = [object valueForKey: key];
    NSMutableArray *list = [groups objectForKey: keyForObject];
    if (!list) {
      list = [NSMutableArray arrayWithCapacity: 5];
      [groups setObject: list forKey: keyForObject];
    }
    [list addObject: object];
  }
  return [groups autorelease];
}

@end

// ------------------------------------------------------------------------------------------------

@implementation NSDate (PsiToolkit)

+ (NSDate *) psDaysAgo: (NSInteger) days {
  return [NSDate psDaysFromNow: -days];
}

+ (NSDate *) psDaysFromNow: (NSInteger) days {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *interval = [[NSDateComponents alloc] init];
  [interval setDay: days];
  NSDate *date = [calendar dateByAddingComponents: interval toDate: [NSDate date] options: 0];
  [interval release];
  return date;
}

+ (NSDateFormatter *) psJSONDateFormatter {
  static NSDateFormatter *formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
  }
  return formatter;
}

- (BOOL) psIsEarlierOrSameDay: (NSDate *) otherDate {
  NSDate *current = [self psMidnight];
  NSDate *other = [otherDate psMidnight];
  return ([current earlierDate: other] == current);
}

- (NSDate *) psMidnight {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSUInteger fieldFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
  NSDateComponents *fields = [calendar components: fieldFlags fromDate: self];
  return [calendar dateFromComponents: fields];
}

- (NSString *) psJSONDateFormat {
  return [[NSDate psJSONDateFormatter] stringFromDate: self];
}

@end

// ------------------------------------------------------------------------------------------------

@implementation NSDictionary (PsiToolkit)

+ (NSDictionary *) psDictionaryWithKeysAndObjects: (id) firstObject, ... {
  if (!firstObject) {
    return [NSDictionary dictionary];
  } else {
    va_list args;
    va_start(args, firstObject);

    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity: 5];
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity: 5];
    id object = firstObject;
    BOOL isKey = YES;

    do {
      if (isKey) {
        [keys addObject: object];
      } else {
        [objects addObject: object];
      }
      object = va_arg(args, id);
      isKey = !isKey;
    } while (object);

    va_end(args);

    NSDictionary *result = [NSDictionary dictionaryWithObjects: objects forKeys: keys];
    [keys release];
    [objects release];
    return result;
  }
}

@end

// ------------------------------------------------------------------------------------------------

@implementation NSNull (PsiToolkit)

- (BOOL) psIsPresent {
  return NO;
}

@end

// ------------------------------------------------------------------------------------------------

@implementation NSString (PsiToolkit)

+ (NSString *) psStringWithFormEncodedFields: (NSDictionary *) fields {
  NSMutableArray *parts = [[NSMutableArray alloc] initWithCapacity: fields.count];
  for (NSString *field in fields) {
    [parts addObject: PSFormat(@"%@=%@", field, [fields objectForKey: field])];
  }

  NSString *result = [parts componentsJoinedByString: @"&"];
  [parts release];
  return result;
}

+ (NSString *) psStringWithFormEncodedFields: (NSDictionary *) fields ofModelNamed: (NSString *) name {
  NSMutableArray *parts = [[NSMutableArray alloc] initWithCapacity: fields.count];
  for (NSString *field in fields) {
    [parts addObject: PSFormat(@"%@[%@]=%@", name, field, [fields objectForKey: field])];
  }

  NSString *result = [parts componentsJoinedByString: @"&"];
  [parts release];
  return result;
}

- (BOOL) psIsPresent {
  return ([[self psTrimmedString] length] > 0);
}

- (BOOL) psContainsString: (NSString *) substring {
  NSRange found = [self rangeOfString: substring];
  return (found.location != NSNotFound);
}

- (NSString *) psCamelizedString {
  NSArray *words = [self componentsSeparatedByString: @"_"];
  if (words.count == 1) {
    return [[self copy] autorelease];
  } else {
    NSMutableString *camelized = [[NSMutableString alloc] initWithString: [words objectAtIndex: 0]];
    for (NSInteger i = 1; i < words.count; i++) {
      [camelized appendString: [[words objectAtIndex: i] capitalizedString]];
    }
    return [camelized autorelease];
  }
}

- (NSString *) psPluralizedString {
  static NSDictionary *exceptions;
  if (!exceptions) {
    exceptions = [PSHash(@"person", @"people") retain];
  }

  NSString *downcased = [self lowercaseString];
  NSString *result = [exceptions objectForKey: downcased];
  if (result) {
    return result;
  } else if ([downcased hasSuffix: @"s"]) {
    return downcased;
  } else {
    return [downcased stringByAppendingString: @"s"];
  }
}

- (NSString *) psStringWithPercentEscapesForFormValues {
  CFStringRef escapedSymbols = CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/");
  CFStringRef string = (CFStringRef) [[self mutableCopy] autorelease];
  NSString *escaped =
    (NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, string, NULL, escapedSymbols, kCFStringEncodingUTF8);
  return NSMakeCollectable([escaped autorelease]);
}

- (NSString *) psStringWithUppercaseFirstLetter {
  NSString *head = [self substringToIndex: 1];
  NSString *tail = [self substringFromIndex: 1];
  return [[head uppercaseString] stringByAppendingString: tail];
}

- (NSString *) psTrimmedString {
  return [self stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *) psUnderscoreSeparatedString {
  NSCharacterSet *uppercaseLetters = [NSCharacterSet uppercaseLetterCharacterSet];
  NSScanner *scanner = [NSScanner localizedScannerWithString: self];
  [scanner setCaseSensitive: YES];
  NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity: self.length];
  NSString *part;
  BOOL found;

  while (true) {
    found = [scanner scanUpToCharactersFromSet: uppercaseLetters intoString: &part];
    if (!found) {
      break;
    }

    [buffer appendString: part];

    found = [scanner scanCharactersFromSet: uppercaseLetters intoString: &part];
    if (!found) {
      break;
    }

    if (![buffer hasSuffix: @"_"]) {
      [buffer appendString: @"_"];
    }

    if (part.length > 1) {
      [buffer appendString: [[part substringToIndex: part.length - 1] lowercaseString]];
      [buffer appendString: @"_"];
      [buffer appendString: [[part substringFromIndex: part.length - 1] lowercaseString]];
    } else {
      [buffer appendString: [part lowercaseString]];
    }
  }

  NSString *result = [NSString stringWithString: buffer];
  [buffer release];
  return result;
}

@end
