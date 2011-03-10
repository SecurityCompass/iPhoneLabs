// Utilities.m

#import "Utilities.h"

/**
 * Display a UIAlertView with the specified message. If the delegate is also specified then the alert will call it's
 * delegate methods.
 */

void BankDisplayAlertView(NSString* message, id delegate)
{
	UIAlertView* alert = [[[UIAlertView alloc] initWithTitle: nil message: message
		delegate: delegate cancelButtonTitle: @"OK" otherButtonTitles: nil] autorelease];
	[alert show];
}

/**
 * Display a UIAlertView with the specified error. The error's localized message is presented in the alert. If the
 * delegate is also specified then the alert will call it's delegate methods.
 */

void BankDisplayErrorAlertView(NSError* error, id delegate)
{
	BankDisplayAlertView([error localizedDescription], delegate);
}

/**
 * Display a UIAlertView with the specified bank application error code. The error code's descriptive message is looked
 * up in the Errors.plist file. If the delegate is also specified then the alert will call it's delegate methods.
 */

void BankDisplayApplicationErrorAlertView(NSString* applicationError, id delegate)
{
	static NSDictionary* errorMessages = nil;

	if (errorMessages == nil) {
		errorMessages = [[NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Errors" ofType: @"plist"]] retain];
	}

	NSString* errorMessage = [errorMessages objectForKey: applicationError];
	if (errorMessage == nil) {
		errorMessage = [NSString stringWithFormat: @"An unknown application error has occurred (%@)", applicationError];
	}

	BankDisplayAlertView(errorMessage, delegate);
}

/**
 * Escape a string for use in a http query string according to RFC 3875;
 */

NSString* BankEscapeQueryParameter(NSString* string)
{
	NSString* escaped = (NSString* )CFURLCreateStringByAddingPercentEscapes(
		NULL,
		(CFStringRef) string,
		NULL,
		CFSTR(";/?:@&=$+{}<>,"),
		CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)
	);
	return [escaped autorelease];
}
