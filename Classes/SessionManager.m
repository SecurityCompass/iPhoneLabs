// SessionManager.m

#import "SessionManager.h"

/**
 * The SessionManager is a simple singleton that stores the current session key and the encryption key. This is
 * a singleton because that is a preferred pattern in Cocoa to replace globals.
 */

@implementation SessionManager

@synthesize sessionKey = _sessionKey;
@synthesize encryptionKey = _encryptionKey;

/**
 * Return the shared singleton instance of the SessionManager.
 */

+ (id) sharedSessionManager
{
	static SessionManager* sharedSessionManager = nil;

	@synchronized (self) {
		if (sharedSessionManager == nil) {
			sharedSessionManager = [self new];
		}
	}
	return sharedSessionManager;
}

/**
 * Invalidate the current session. Simply sets the session key and encryption key to nil.
 */

- (void) invalidate
{
	self.sessionKey = nil;
	self.encryptionKey = nil;
}

@end
