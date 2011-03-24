// Networking.m

#import "JSON.h"
#import "ASIFormDataRequest.h"

#import "Account.h"
#import "SessionManager.h"
#import "Constants.h"
#import "Utilities.h"
#import "Networking.h"
#import "Crypto.h"

/**
 * Login to the bank service. Returns the session key on success. On failure it returns nil and sets
 * the error and applicationError parameters.
 */

NSString* BankLogin(NSString* username, NSString* password, NSError** error, NSString** applicationError)
{
	*error = nil;
	*applicationError = nil;

	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSURL* url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/login", [defaults valueForKey: @"BankServiceURL"]]];

	ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL: url];
	[request setPostValue: username forKey: @"username"];
	[request setPostValue: password forKey: @"password"];
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
		// Decrypt the stored username and password with the secret key
	
		NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		
		NSString* username = BankDecryptString(
			[defaults objectForKey: @"Username"],
			[[SessionManager sharedSessionManager] encryptionKey],
			[defaults objectForKey: @"UsernameIV"]
		);

		NSString* password = BankDecryptString(
			[defaults objectForKey: @"Password"],
			[[SessionManager sharedSessionManager] encryptionKey],
			[defaults objectForKey: @"PasswordIV"]
		);
		
		if (username == nil || password == nil) {
			return nil;
		}
		
		// Login to the bank so that we get a new session
		
		sessionKey = BankLogin(username, password, error, applicationError);
		if (sessionKey == nil) {
			return nil;
		}
		[[SessionManager sharedSessionManager] setSessionKey: sessionKey];
	}
	
	return sessionKey;
}

static NSArray* _BankGetAccounts(NSString* sessionKey, NSError** error, NSString** applicationError)
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSURL* url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/accounts?session_key=%@",
		[defaults stringForKey: @"BankServiceURL"], BankEscapeQueryParameter(sessionKey)]];

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
	
	NSMutableArray* result = nil;
	
	if (accounts != nil)
	{
		result = [NSMutableArray array];
	
		for (NSDictionary* dict in accounts)
		{
			Account* account = [[[Account alloc] initWithNumber: [[dict objectForKey: @"account_number"] stringValue]
				type: [dict objectForKey: @"type"] balance: [dict objectForKey: @"balance"]] autorelease];
			[result addObject: account];
		}
	}
	
	
	return result;
}

BOOL _BankTransferFunds(NSString* sessionKey, NSString* fromAccount, NSString* toAccount, NSString* amount, NSError** error, NSString** applicationError)
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSURL* url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/transfer?session_key=%@",
		[defaults stringForKey: @"BankServiceURL"], BankEscapeQueryParameter(sessionKey)]];

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
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSURL* url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/statement?session_key=%@",
		[defaults stringForKey: @"BankServiceURL"], BankEscapeQueryParameter(sessionKey)]];
	
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
