// Networking.m

#import "JSON.h"
#import "ASIFormDataRequest.h"

#import "SessionManager.h"
#import "Constants.h"
#import "Utilities.h"
#import "Networking.h"

/**
 * Login to the bank service. Returns the session key on success. On failure it returns nil and sets
 * the error and applicationError parameters.
 */

NSString* BankLogin(NSString* username, NSString* password, NSError** error, NSString** applicationError)
{
	*error = nil;
	*applicationError = nil;

	NSURL* url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/login", kBankServiceURL]];

	ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL: url];
	[request setPostValue: [[NSUserDefaults standardUserDefaults] objectForKey: @"Username"] forKey: @"username"];
	[request setPostValue: [[NSUserDefaults standardUserDefaults] objectForKey: @"Password"] forKey: @"password"];
	[request startSynchronous];
	
	if (request.error != nil) {
		*error = request.error;
		return nil;
	}
	
	NSDictionary* dictionary = [[request responseString] JSONValue];
	if ([dictionary objectForKey: @"error"]) {
		*applicationError = [dictionary objectForKey: @"error"];
		return nil;
	}

	return [dictionary objectForKey: @"key"];
}

static NSString* _BankRefreshSession(BOOL force, NSError** error, NSString** applicationError)
{
	// Refresh the session if we do not have one

	NSString* sessionKey = [[SessionManager sharedSessionManager] sessionKey];
	if (force == YES || sessionKey == nil)
	{
		NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		sessionKey = BankLogin([defaults objectForKey: @"Username"], [defaults objectForKey: @"Password"], error, applicationError);
		if (sessionKey == nil) {
			return nil;
		}
		[[SessionManager sharedSessionManager] setSessionKey: sessionKey];
	}
	
	return sessionKey;
}

static NSArray* _BankGetAccounts(NSString* sessionKey, NSError** error, NSString** applicationError)
{
	NSURL* url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/accounts?session_key=%@", kBankServiceURL, BankEscapeQueryParameter(sessionKey)]];
	ASIHTTPRequest* request= [ASIHTTPRequest requestWithURL: url];
	[request startSynchronous];
	
	if (request.error != nil) {
		*error = request.error;
		return nil;
	}

	id response = [[request responseString] JSONValue];
	
	if ([response isKindOfClass: [NSDictionary class]] && [response objectForKey: @"error"]) {
		*applicationError = [response objectForKey: @"error"];
		return nil;
	}
	
	return response;
}

/**
 * Call the bank API to load the list of accounts. Returns an array of dictionaries with on success. On failure it
 * returns nil and sets the error and applicationError parameters.
 */

NSArray* BankGetAccounts(NSError** error, NSString** applicationError)
{
	*error = nil;
	*applicationError = nil;

	NSString* sessionKey = _BankRefreshSession(NO, error, applicationError);
	if (sessionKey == nil) {
		return nil;
	}

	//

	NSArray* accounts = _BankGetAccounts(sessionKey, error, applicationError);
	if (accounts == nil && [*applicationError isEqualToString: @"E2"])
	{
		sessionKey = _BankRefreshSession(YES, error, applicationError);
		if (sessionKey == nil) {
			return nil;
		}
		
		accounts = _BankGetAccounts(sessionKey, error, applicationError);
	}
	
	return accounts;
}

BOOL _BankTransferFunds(NSString* sessionKey, NSString* fromAccount, NSString* toAccount, NSString* amount, NSError** error, NSString** applicationError)
{
	NSURL* url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/transfer?session_key=%@", kBankServiceURL, BankEscapeQueryParameter(sessionKey)]];

	ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL: url];
	//[request setPostValue: sessionKey forKey: @"session_key"];
	[request setPostValue: fromAccount forKey: @"from_account"];
	[request setPostValue: toAccount forKey: @"to_account"];
	[request setPostValue: amount forKey: @"amount"];
	[request startSynchronous];
	
	if (request.error != nil) {
		*error = request.error;
		return NO;
	}
	
	id response = [[request responseString] JSONValue];
	
	if ([response isKindOfClass: [NSDictionary class]] && [response objectForKey: @"error"]) {
		*applicationError = [response objectForKey: @"error"];
		return NO;
	}
	
	return YES;
}

/**
 * Call the Bank API to transfer funds. Returns TRUE on success or FALSE on failure. In case of failure it also
 * sets the error and applicationError.
 */

BOOL BankTransferFunds(NSString* fromAccount, NSString* toAccount, NSString* amount, NSError** error, NSString** applicationError)
{
	NSLog(@"Transferring %@ from %@ to %@", amount, fromAccount, toAccount);

	*error = nil;
	*applicationError = nil;

	NSString* sessionKey = _BankRefreshSession(NO, error, applicationError);
	if (sessionKey == nil) {
		return NO;
	}

	//

	BOOL success = _BankTransferFunds(sessionKey, fromAccount, toAccount, amount, error, applicationError);
	if (success == NO && [*applicationError isEqualToString: @"E2"])
	{
		sessionKey = _BankRefreshSession(YES, error, applicationError);
		if (sessionKey == nil) {
			return NO;
		}
		
		success = _BankTransferFunds(sessionKey, fromAccount, toAccount, amount, error, applicationError);
	}

	return success;
}

NSString* _BankDownloadStatement(NSString* sessionKey, NSError** error, NSString** applicationError)
{
	NSURL* url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/statement?session_key=%@", kBankServiceURL,
		BankEscapeQueryParameter(sessionKey)]];
	
	ASIHTTPRequest* request= [ASIHTTPRequest requestWithURL: url];
	[request startSynchronous];
	
	if (request.error != nil) {
		*error = request.error;
		return nil;
	}

	// This is a bit of a kludge. The API can also return JSON in case of an error. So we try to recognize
	// that by checking if the response is a JSON dictionary. Not perfect but works.
	
	if ([[request responseString] hasPrefix: @"{"])
	{
		NSDictionary* response = [[request responseString] JSONValue];
		if ([response isKindOfClass: [NSDictionary class]] && [response objectForKey: @"error"]) {
			*applicationError = [response objectForKey: @"error"];
			return nil;
		}
	}

	return [request responseString];
}

/**
 * Call the bank API to download the currently available statement. Returns the contents of the statement (html) as
 * a result on success. Returns nil and sets the error and applicationError parameters on failure.
 */

NSString* BankDownloadStatement(NSError** error, NSString** applicationError)
{
	*error = nil;
	*applicationError = nil;

	NSString* sessionKey = _BankRefreshSession(NO, error, applicationError);
	if (sessionKey == nil) {
		return NO;
	}

	//

	NSString* statement = _BankDownloadStatement(sessionKey, error, applicationError);
	if (statement == nil && [*applicationError isEqualToString: @"E2"])
	{
		sessionKey = _BankRefreshSession(YES, error, applicationError);
		if (sessionKey == nil) {
			return NO;
		}
		
		statement = _BankDownloadStatement(sessionKey, error, applicationError);
	}
	
	return statement;
}
