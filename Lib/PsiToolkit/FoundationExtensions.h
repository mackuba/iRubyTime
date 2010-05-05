// -------------------------------------------------------
// FoundationExtensions.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

@interface NSArray (PsiToolkit)
- (NSArray *) psCompact;
- (NSArray *) psSortedArrayUsingField: (NSString *) field ascending: (BOOL) ascending;
- (NSDictionary *) psGroupByKey: (NSString *) key;
@end

@interface NSDate (PsiToolkit)
+ (NSDateFormatter *) psJSONDateFormatter;
- (BOOL) psIsEarlierOrSameDay: (NSDate *) otherDate;
- (NSDate *) psDaysAgo: (NSInteger) days;
- (NSDate *) psDaysFromNow: (NSInteger) days;
- (NSDate *) psMidnight;
- (NSString *) psJSONDateFormat;
@end

@interface NSNull (PsiToolkit)
- (BOOL) psIsBlank;
@end

@interface NSString (PsiToolkit)
- (BOOL) psIsBlank;
- (NSString *) psCamelizedString;
- (NSString *) psStringWithPercentEscapesForFormValues;
- (NSString *) psStringWithUppercaseFirstLetter;
- (NSString *) psTrimmedString;
@end
