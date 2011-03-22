// BankAppDelegate.m

#import "BankAppDelegate.h"
#import "SessionManager.h"
#import "MenuViewController.h"
#import "Utilities.h"

@implementation BankAppDelegate

@synthesize window = _window;

- (void) login
{
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
	// Store the username and password in the application's preferences
	
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject: _masterPassword forKey: @"MasterPassword"];
	[userDefaults setObject: username forKey: @"Username"];
	[userDefaults setObject: password forKey: @"Password"];
	[userDefaults synchronize];
	
	// Store the session in our session manager

	SessionManager* sessionManager = [SessionManager sharedSessionManager];
	sessionManager.sessionKey = sessionKey;

	// Replace the LoginViewController with the MenuViewController
	
	[_navigationController popViewControllerAnimated: NO];
	
	MenuViewController* menuViewController = [[MenuViewController new] autorelease];
	if (menuViewController != nil) {
		[_navigationController setViewControllers: [NSArray arrayWithObject: menuViewController]];
	}
}

- (void) setupPasswordViewController:(SetupPasswordViewController *)vc didSetupPassword:(NSString *)password
{
	// Temporarily keep the master password around. We will not store it until the user has also logged in.

	_masterPassword = [password retain];
	
	// Open the login dialog to let the user login to the web app. If that succeeds we store everything in
	// the user's preferences.
	
	LoginViewController* loginViewController = [[LoginViewController new] autorelease];
	loginViewController.delegate = self;
	[_navigationController setViewControllers: [NSArray arrayWithObject: loginViewController]];	
}

- (void) setupApplication
{
	SetupPasswordViewController* setupPasswordViewController = [[SetupPasswordViewController new] autorelease];
	setupPasswordViewController.delegate = self;
	[_navigationController setViewControllers: [NSArray arrayWithObject: setupPasswordViewController] animated: NO];
}

#pragma mark -

- (BOOL) checkPasswordViewController:(CheckPasswordViewController *)vc didEnterPassword:(NSString *)password
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSString* correctMasterPassword = [userDefaults objectForKey: @"MasterPassword"];

	if ([password isEqualToString: correctMasterPassword])
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
