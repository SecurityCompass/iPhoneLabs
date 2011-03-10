//  Networking.h

#import <Foundation/Foundation.h>

NSString* BankLogin(NSString* username, NSString* password, NSError** error, NSString** applicationError);
NSArray* BankGetAccounts(NSError** error, NSString** applicationError);
BOOL BankTransferFunds(NSString* fromAccount, NSString* toAccount, NSString* amount, NSError** error, NSString** applicationError);