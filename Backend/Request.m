#import "NSString+BSJSONAdditions.h"
#import "Constants.h"
#import "Request.h"
#import "Utils.h"

#define SetHeader(key, value) [self setValue: value forHTTPHeaderField: key]

@implementation Request

@synthesize type;
SynthesizeAndReleaseLater(response, receivedText, sentText, connection);

// -------------------------------------------------------------------------------------------
#pragma mark Initializers

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
    SetHeader(@"Accept", @"application/json");
    if (sentText) {
      //SetHeader(@"Content-Type", @"application/json");
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
