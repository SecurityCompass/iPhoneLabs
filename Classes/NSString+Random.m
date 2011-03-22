//  NSString+Random.m

#import "NSString+Random.h"

@implementation NSString (NSString_Random)

+ (id) randomStringWithLength: (NSUInteger) length
{
	static char characters[64] = "1234567890abcdefghijklmnopqrstuvwxyzABCDFGHIJKLMNOPQRSTUVWXYZ";

	id result = nil;
	
	char* buffer = malloc(length);
	if (buffer != NULL)
	{
		for (NSUInteger i = 0; i < length; i++) {
			buffer[i] = characters[random() % 64];
		}
	
		result = [[[self alloc] initWithBytesNoCopy: buffer length: length encoding: NSUTF8StringEncoding freeWhenDone: YES] autorelease];
	}
	
	return result;
}

@end
