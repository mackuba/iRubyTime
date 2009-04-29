// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

typedef enum {
  RTAuthenticationRequest = 1,
  RTActivityIndexRequest
} RTRequestType;

@interface Request : NSMutableURLRequest {
  RTRequestType type;
  NSURLResponse *response;
  NSString *sentText;
  NSMutableString *receivedText;
  NSURLConnection *connection;
}

@property (nonatomic) RTRequestType type;
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, readonly) NSString *sentText;
@property (nonatomic, readonly) NSMutableString *receivedText;

- (id) initWithURL: (NSString *) url
            method: (NSString *) method
              text: (NSString *) text
              type: (RTRequestType) type;

- (id) initWithURL: (NSString *) url
            method: (NSString *) method
              type: (RTRequestType) type;

- (id) initWithURL: (NSString *) url
              type: (RTRequestType) type;

- (void) appendReceivedText: (NSString *) text;

@end
