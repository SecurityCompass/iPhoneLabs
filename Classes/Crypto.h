// Crypto.h

#import <Foundation/Foundation.h>

NSData* BankGenerateRandomSalt(NSUInteger length);
NSData* BankGenerateRandomIV();

NSData* BankHashLocalPassword(NSString* password, NSData* salt);

NSData* BankEncryptString(NSString* plaintext, NSData* key, NSData* iv);
NSString* BankDecryptString(NSData* ciphertext, NSData* key, NSData* iv);
