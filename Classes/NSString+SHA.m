// NString+SHA.m

#import "NSString+SHA.h"

#include "CommonCrypto/CommonDigest.h"

@implementation NSString (SHA)

- (NSData*) SHA256Hash
{
	NSData* result = nil;

	NSData* data = [self dataUsingEncoding: NSUTF8StringEncoding];
	if (data != nil)
	{
		unsigned char md[CC_SHA256_DIGEST_LENGTH];
		CC_SHA256([data bytes], [data length], md);		
		result = [NSData dataWithBytes: md length: CC_SHA256_DIGEST_LENGTH];
	}
	
	return result;
}

@end
