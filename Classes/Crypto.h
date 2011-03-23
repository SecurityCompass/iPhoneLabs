// Crypto.h

#import <Foundation/Foundation.h>

NSData* BankGenerateRandomSalt(NSUInteger length);
NSData* BankGenerateRandomIV();

NSData* BankHashLocalPassword(NSString* password, NSData* salt);

NSData* BankEncryptString(NSString* string, NSData* key, NSData* iv);
NSData* BankDecryptString(NSString* string, NSData* key, NSData* iv);
