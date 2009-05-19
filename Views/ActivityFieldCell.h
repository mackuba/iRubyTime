// -------------------------------------------------------
// ActivityFieldCell.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@interface ActivityFieldCell : UITableViewCell {
  UILabel *fieldLabel;
  UILabel *valueLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *fieldLabel;
@property (nonatomic, retain) IBOutlet UILabel *valueLabel;

- (void) displayFieldName: (NSString *) name value: (NSString *) value;

@end
