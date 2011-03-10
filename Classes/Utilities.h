//  Utilities.h

#import <Foundation/Foundation.h>

void BankDisplayAlertView(NSString* message, id delegate);
void BankDisplayErrorAlertView(NSError* error, id delegate);
void BankDisplayApplicationErrorAlertView(NSString* applicationError, id delegate);

NSString* BankEscapeQueryParameter(NSString* string);
