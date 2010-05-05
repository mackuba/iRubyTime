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

@synthesize type, response, receivedText, sentText, connection, info;
PSReleaseOnDealloc(response, receivedText, sentText, connection, info);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithURL: (NSString *) url
            method: (NSString *) method
              type: (RTRequestType) requestType
              text: (NSString *) text {
  NSURL *wrappedUrl = [NSURL URLWithString: url];
  self = [super initWithURL: wrappedUrl cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 20];
  if (self) {
    self.type = requestType;
    self.HTTPMethod = method;
    receivedText = [[NSMutableString alloc] init];
    sentText = [text copy];
    [self setValue: @"application/json" forHTTPHeaderField: @"Accept"];
    NSString *apiVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"RubyTimeAPIVersion"];
    [self setValue: apiVersion forHTTPHeaderField: @"X-API-Version"];
    if (sentText) {
      self.HTTPBody = [sentText dataUsingEncoding: NSUTF8StringEncoding];
      [self setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    }
  }
  return self;
}

// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

- (void) appendReceivedText: (NSString *) text {
  [receivedText appendString: text];
}

@end
