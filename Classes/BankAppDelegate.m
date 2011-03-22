// BankAppDelegate.m

#import "NSString+SHA.h"
#import "BankAppDelegate.h"
#import "SessionManager.h"
#import "MenuViewController.h"
#import "Utilities.h"

@implementation BankAppDelegate

@synthesize window = _window;

- (void) setupPasswordViewController:(SetupPasswordViewController *)vc didSetupPassword:(NSString *)password
{
	// Store the username and password in the application's preferences. We also store the password as a
	// SHA256 hashed value.
	
	NSData* hashedMasterPassword = [password SHA256Hash];
	
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject: hashedMasterPassword forKey: @"MasterPassword"];
	[userDefaults setObject: _username forKey: @"Username"];
	[userDefaults setObject: _password forKey: @"Password"];
	[userDefaults synchronize];

	[_username release];
	_username = nil;
	
	[_password release];
	_password = nil;
	
	// Replace the LoginViewController with the MenuViewController
	
	[_navigationController popViewControllerAnimated: NO];
	
	MenuViewController* menuViewController = [[MenuViewController new] autorelease];
	if (menuViewController != nil) {
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

- (BOOL) checkPasswordViewController:(CheckPasswordViewController *)vc didEnterPassword:(NSString *)password
{
	NSString* hashedPassword = [password SHA256Hash];

	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSData* correctHashedMasterPassword = [userDefaults objectForKey: @"MasterPassword"];

	if ([hashedPassword isEqualToData: correctHashedMasterPassword])
	{
		MenuViewController* menuViewController = [[MenuViewController new] autorelease];
		if (menuViewController != nil) {
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

- (BOOL) application: (UIApplication*) application didFinishLaunchingWithOptions: (NSDictionary*) launchOptions
{
	// The root of our application is a UINavigationViewController. We will push all views on it.
	
	_navigationController = [UINavigationController new];
	if (_navigationController != nil) {
		[self.window addSubview: _navigationController.view];
		[self.window makeKeyAndVisible];
	}

	// If we do not have an internal password configured then we ask the user to do that first. Otherwise we
	// ask for the internal password and then enter the app. (We assume that having the internal password
	// means that the user has also logged in to the web application and that we have his credentials)
	
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults objectForKey: @"MasterPassword"] == nil) {	
		[self setupApplication];
	} else {
		[self unlockApplication];
	}

    return YES;
}

- (void) applicationWillResignActive:(UIApplication *)application
{
	// If we are put in the background then go to the unlock screen. But only if
	// the app was configured with both bank account info and internal password.

	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults objectForKey: @"MasterPassword"] != nil) {
		[[SessionManager sharedSessionManager] invalidate];
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
