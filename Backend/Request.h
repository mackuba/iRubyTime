// -------------------------------------------------------
// Request.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

typedef enum {
  RTAuthenticationRequest = 1,
  RTActivityIndexRequest,
  RTProjectIndexRequest,
  RTCreateActivityRequest,
  RTEditActivityRequest,
  RTDeleteActivityRequest
} RTRequestType;

@interface Request : NSMutableURLRequest {
  RTRequestType type;
  NSURLResponse *response;
  NSString *sentText;
  NSMutableString *receivedText;
  NSURLConnection *connection;
  id info;
}

@property (nonatomic) RTRequestType type;
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, readonly) NSString *sentText;
@property (nonatomic, readonly) NSMutableString *receivedText;
@property (nonatomic, retain) id info;

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
