//
//  ActivityType.h
//  RubyTime
//
//  Created by Anna Lesniak on 12/3/10.
//  Copyright 2010 (c). All rights reserved.
//

@interface ActivityType : PSModel {}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger position;
@property (nonatomic, retain) NSMutableArray *availableSubactivityTypes;
@property (nonatomic, assign) BOOL isSubtype;

- (BOOL) hasAvailableSubactivityTypes;

@end
