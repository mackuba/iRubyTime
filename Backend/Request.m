// -------------------------------------------------------
// Request.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Request.h"
#import "Utils.h"
#import "NSString+BSJSONAdditions.h"

@implementation Request

@synthesize type;
SynthesizeAndReleaseLater(response, receivedText, sentText, connection);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithURL: (NSString *) url
            method: (NSString *) method
              text: (NSString *) text
              type: (RTRequestType) requestType {
  self = [super initWithURL: [NSURL URLWithString: url]
                cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
            timeoutInterval: 15];
  if (self) {
    self.type = requestType;
    self.HTTPMethod = method;
    receivedText = [[NSMutableString alloc] init];
    sentText = [text copy];
    [self setValue: @"application/json" forHTTPHeaderField: @"Accept"];
    if (sentText) {
      // [self setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
      self.HTTPBody = [sentText dataUsingEncoding: NSUTF8StringEncoding];
    }
  }
  return self;
}

- (id) initWithURL: (NSString *) url
            method: (NSString *) method
              type: (RTRequestType) requestType {
  return [self initWithURL: url method: method text: @"" type: requestType];
}

- (id) initWithURL: (NSString *) url
              type: (RTRequestType) requestType {
  return [self initWithURL: url method: @"GET" text: @"" type: requestType];
}

// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

- (void) appendReceivedText: (NSString *) text {
  [receivedText appendString: text];
}

@end
