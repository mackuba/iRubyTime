// -------------------------------------------------------
// ActivityFieldCell.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "ActivityFieldCell.h"
#import "Utils.h"

@implementation ActivityFieldCell

SynthesizeAndReleaseLater(fieldLabel, valueLabel);

- (void) displayFieldName: (NSString *) name value: (NSString *) value {
  self.fieldLabel.text = name;
  self.valueLabel.text = value;
}

@end
