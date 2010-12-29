// -------------------------------------------------------
// Project.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

@class ActivityType;

@interface Project : PSModel {}

@property (nonatomic, copy) NSString *name;
@property (nonatomic) BOOL hasActivities;
@property (nonatomic, retain) NSMutableArray *availableActivityTypes;

+ (NSArray *) allWithActivities;
- (ActivityType *) activityTypeWithId: (NSNumber *) recordId;
- (BOOL) hasAvailableActivityTypes;

@end
