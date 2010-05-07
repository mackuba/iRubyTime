// -------------------------------------------------------
// RecordChoiceController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@interface RecordChoiceController : UITableViewController {
  Class model;
  id delegate;
  BOOL allowNil;
  BOOL closeOnSelection;
}

@property (nonatomic) BOOL closeOnSelection;

- (id) initWithModel: (Class) model delegate: (id) delegate allowNil: (BOOL) allowNil;
- (PSModel *) recordAtPath: (NSIndexPath *) path;

@end
