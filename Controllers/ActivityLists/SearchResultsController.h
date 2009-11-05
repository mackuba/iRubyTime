// -------------------------------------------------------
// SearchResultsController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>
#import "ActivityListController.h"

@class SearchFormController;

@interface SearchResultsController : ActivityListController {
  SearchFormController *parentController;
}

- (id) initWithParentController: (SearchFormController *) parent
                      connector: (RubyTimeConnector *) rtConnector;

@end
