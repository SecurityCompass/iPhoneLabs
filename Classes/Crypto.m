//  Crypto.m

#include <openssl/evp.h>
#include <openssl/rand.h>

#import "Crypto.h"

#pragma mark Private API
#pragma mark -

/**
 * Generate a SHA256 hash of the specified NSData instance. Returns an NSData instance containing
 * the hash or nil if the operation failed.
 */
 
static NSData* _SHA256Data(NSData* data)
{
	NSData* result = nil;

	const EVP_MD* md = EVP_sha256();
	if (md != NULL)
	{
		unsigned char md_value[EVP_MAX_MD_SIZE];
		unsigned int md_len;	
		EVP_MD_CTX mdctx;

		EVP_MD_CTX_init(&mdctx);
		EVP_DigestInit_ex(&mdctx, md, NULL);
		EVP_DigestUpdate(&mdctx, [data bytes], [data length]);
		EVP_DigestFinal_ex(&mdctx, md_value, &md_len);
		EVP_MD_CTX_cleanup(&mdctx);
		
		result = [NSData dataWithBytes: md_value length: md_len];
	}
	
	return result;
}

/**
 * Generate an NSData instance of the specified length filled with random data. Returns nil
 * if the operation failed. This code uses the standard OpenSSL random generator.
 */

static NSData* _GenerateRandomData(NSUInteger length)
{
	id result = nil;

	unsigned char* buffer = (unsigned char*) malloc(length);
	if (buffer != NULL) {
		if (RAND_bytes(buffer, length) != 1) {
			free(buffer);
		} else {
			result = [NSData dataWithBytesNoCopy: buffer length: length freeWhenDone: YES];
		}
	}
	
	return result;
}

#pragma mark Public API
#pragma mark -

NSData* BankGenerateRandomSalt(NSUInteger length)
{
	return _GenerateRandomData(length);
}

NSData* BankGenerateRandomIV()
{
	return _GenerateRandomData(16);
}

NSData* BankHashLocalPassword(NSString* password, NSData* salt)
{
	// Turn salt + password into data

	NSMutableData* data = [NSMutableData dataWithData: salt];
	[data appendData: [password dataUsingEncoding: NSUTF8StringEncoding]];
	
	// Hash the data 1000 times with SHA256
	
	for (int i = 0; i < 1000; i++) {
		[data setData: _SHA256Data(data)];
	}
	
	return data;
}

NSData* BankEncryptString(NSString* string, NSData* key, NSData* iv)
{
	return nil;
}

NSData* BankDecryptString(NSString* string, NSData* key, NSData* iv)
{
	return nil;
}
