// BankAppDelegate.m

#import "NSString+SHA.h"
#import "NSString+Random.h"
#import "BankAppDelegate.h"
#import "SessionManager.h"
#import "MenuViewController.h"

#import "Crypto.h"
#import "Constants.h"
#import "Utilities.h"

@implementation BankAppDelegate

@synthesize window = _window;

- (void) setupPasswordViewController:(SetupPasswordViewController *)vc didSetupPassword:(NSString *) localPassword
{
	// Derive the encryption key from the local password and store it in the session

	NSData* derivedEncryptionKey = BankDeriveEncryptionKey(localPassword, @"salt");
	[[SessionManager sharedSessionManager] setEncryptionKey: derivedEncryptionKey];
	
	// Store the username and password in the application's preferences. These are encrypted using AES256 with a
	// key that is derived from the local password. We also store the master password as a SHA256 hashed value.
	
	NSData* hashedLocalPasswordSalt = BankGenerateRandomSalt(32);
	NSData* hashedLocalPassword = BankHashLocalPassword(localPassword, hashedLocalPasswordSalt);
	
	NSData* encryptedUsernameIV = BankGenerateRandomIV();
	NSData* encryptedUsername = BankEncryptString(_username, derivedEncryptionKey, encryptedUsernameIV);

	NSData* encryptedPasswordIV = BankGenerateRandomIV();
	NSData* encryptedPassword = BankEncryptString(_password, derivedEncryptionKey, encryptedPasswordIV);
	
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject: hashedLocalPassword forKey: @"LocalPassword"];
	[userDefaults setObject: hashedLocalPasswordSalt forKey: @"LocalPasswordSalt"];
	[userDefaults setObject: encryptedUsername forKey: @"Username"];
	[userDefaults setObject: encryptedUsernameIV forKey: @"UsernameIV"];
	[userDefaults setObject: encryptedPassword forKey: @"Password"];
	[userDefaults setObject: encryptedPasswordIV forKey: @"PasswordIV"];
	[userDefaults synchronize];

	[_username release];
	_username = nil;
	
	[_password release];
	_password = nil;
	
	// Replace the LoginViewController with the MenuViewController
	
	[_navigationController popViewControllerAnimated: NO];
	
	MenuViewController* menuViewController = [[MenuViewController new] autorelease];
	if (menuViewController != nil) {
		menuViewController.delegate = self;
		[_navigationController setViewControllers: [NSArray arrayWithObject: menuViewController]];
	}
}

- (void) loginViewController:(LoginViewController *)loginViewController didFailWithError:(NSError *)error
{
	BankDisplayErrorAlertView(error, nil);
}

- (void) loginViewController:(LoginViewController *)loginViewController didFailWithServerError:(NSString *)applicationError
{
	BankDisplayApplicationErrorAlertView(applicationError, nil);
}

- (void) loginViewController:(LoginViewController *)loginViewController didSucceedWithUsername:(NSString *)username password:(NSString *)password sessionKey:(NSString *)sessionKey
{
	SetupPasswordViewController* setupPasswordViewController = [[SetupPasswordViewController new] autorelease];
	setupPasswordViewController.delegate = self;
	[_navigationController setViewControllers: [NSArray arrayWithObject: setupPasswordViewController] animated: NO];
	
	// Temporarily store the username and password. We store them in the preferences after the user has set a master password.
	
	[_username release];
	_username = [username retain];
	
	[_password release];
	_password = [password retain];
	
	// Store the session in our session manager

	SessionManager* sessionManager = [SessionManager sharedSessionManager];
	sessionManager.sessionKey = sessionKey;
}

- (void) setupApplication
{
	// In case we were in the middle of logging in, kill the saved credentials

	[_username release];
	_username = nil;
	
	[_password release];
	_password = nil;

	// Show the login screen

	LoginViewController* loginViewController = [[LoginViewController new] autorelease];
	loginViewController.delegate = self;
	[_navigationController setViewControllers: [NSArray arrayWithObject: loginViewController]];	
}

#pragma mark -

- (BOOL) checkPasswordViewController:(CheckPasswordViewController *)vc didEnterPassword:(NSString *) localPassword
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSData* correctHashedLocalPasswordSalt = [userDefaults objectForKey: @"LocalPasswordSalt"];
	NSData* correctHashedLocalPassword = [userDefaults objectForKey: @"LocalPassword"];

	NSData* hashedPassword = BankHashLocalPassword(localPassword, correctHashedLocalPasswordSalt);

	if ([hashedPassword isEqualToData: correctHashedLocalPassword])
	{
		// Derive the encryption key from the local password and store it in the session

		NSData* derivedEncryptionKey = BankDeriveEncryptionKey(localPassword, @"salt");
		[[SessionManager sharedSessionManager] setEncryptionKey: derivedEncryptionKey];
	
		// Show the main menu
	
		MenuViewController* menuViewController = [[MenuViewController new] autorelease];
		if (menuViewController != nil) {
			menuViewController.delegate = self;
			[_navigationController setViewControllers: [NSArray arrayWithObject: menuViewController]];
		}
		return YES;
	}
	return NO;
}

- (void) unlockApplication
{
	CheckPasswordViewController* checkPasswordViewController = [[CheckPasswordViewController new] autorelease];
	checkPasswordViewController.delegate = self;
	[_navigationController setViewControllers: [NSArray arrayWithObject: checkPasswordViewController] animated: NO];
}

#pragma mark -

- (void) resetApplication
{
	// Delete all user preference

	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults removeObjectForKey: @"LocalPassword"];
	[userDefaults removeObjectForKey: @"LocalPasswordSalt"];
	[userDefaults removeObjectForKey: @"Username"];
	[userDefaults removeObjectForKey: @"Password"];
	[userDefaults removeObjectForKey: @"Reset"];
	[userDefaults synchronize];

	// Delete all statement files from the ~/Documents directory

	NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
	NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: documentsDirectory error: nil];

	for (NSString* file in files) {
		NSString* path = [documentsDirectory stringByAppendingPathComponent: file];
		[[NSFileManager defaultManager] removeItemAtPath: path error: NULL];
	}

	// Reset the session

	[[SessionManager sharedSessionManager] invalidate];
}

- (void) menuViewControllerDidAskToResetApplication:(MenuViewController *)menuViewController
{
	[self resetApplication];
	[self setupApplication];
}

#pragma mark -

- (BOOL) application: (UIApplication*) application didFinishLaunchingWithOptions: (NSDictionary*) launchOptions
{
	// Setup the defaults
	
	NSMutableDictionary* initialDefaults = [NSMutableDictionary dictionary];
	[initialDefaults setObject: kDefaultBankServiceURL forKey: @"BankServiceURL"];
	[initialDefaults setObject: [NSNumber numberWithBool: NO] forKey: @"Reset"];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults: initialDefaults];
	[[NSUserDefaults standardUserDefaults] synchronize];

	// Check if we need to do a full reset
	
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults boolForKey: @"Reset"] == YES) {
		[self resetApplication];
	}

	// The root of our application is a UINavigationViewController. We will push all views on it.
	
	_navigationController = [UINavigationController new];
	if (_navigationController != nil) {
		[self.window addSubview: _navigationController.view];
		[self.window makeKeyAndVisible];
	}

	// If we do not have an internal password configured then we ask the user to do that first. Otherwise we
	// ask for the internal password and then enter the app. (We assume that having the internal password
	// means that the user has also logged in to the web application and that we have his credentials)
	
	if ([userDefaults objectForKey: @"LocalPassword"] == nil) {	
		[self setupApplication];
	} else {
		[self unlockApplication];
	}

    return YES;
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
	// Check if we need to do a full reset
	
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults boolForKey: @"Reset"] == YES) {
		[self resetApplication];
		[self setupApplication];
	}
}

- (void) applicationWillResignActive:(UIApplication *)application
{
	// If we are put in the background then go to the unlock screen. But only if
	// the app was configured with both bank account info and internal password.

	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults objectForKey: @"LocalPassword"] != nil) {
		// Invalidate the session. This will release the stored password and crypto key.
		[[SessionManager sharedSessionManager] invalidate];
		// Go to the screen that asks for the password
		[self unlockApplication];
	} else {
		[self setupApplication];
	}
}

- (void) dealloc
{
	[_navigationController release];
    [_window release];
    [super dealloc];
}

#pragma mark -

@end
