// SessionManager.h

#import <Foundation/Foundation.h>

@interface SessionManager : NSObject {
  @private
	NSString* _sessionKey;
}

+ (id) sharedSessionManager;

- (void) invalidate;

@property (nonatomic,retain) NSString* sessionKey;

@end
