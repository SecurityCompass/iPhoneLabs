// SessionManager.h

#import <Foundation/Foundation.h>

@interface SessionManager : NSObject {
  @private
	NSString* _sessionKey;
	NSData* _encryptionKey;
}

+ (id) sharedSessionManager;

- (void) invalidate;

@property (nonatomic,retain) NSString* sessionKey;
@property (nonatomic,retain) NSData* encryptionKey;

@end
