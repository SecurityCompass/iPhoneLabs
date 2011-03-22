// LoginViewController.m

#import <QuartzCore/QuartzCore.h>
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "LoginViewController.h"
#import "Constants.h"

/**
 * The LoginViewController handles logging in to the Bank application. Success or failure is reported back to
 * the caller of the view controller through it's LoginViewControllerDelegate protocol. This controller only
 * handles the login and does nothing with the credentials or session key. That is left to the caller.
 */

@implementation LoginViewController

@synthesize delegate = _delegate;

/**
 * Hide the login form controls: the text fields and labels.
 */

- (void) _hideLoginForm
{
	_usernameLabel.hidden = YES;
	_usernameTextField.hidden = YES;
	_passwordLabel.hidden = YES;
	_passwordTextField.hidden = YES;
	
	[_usernameTextField resignFirstResponder];
	[_passwordTextField resignFirstResponder];
}

/**
 * Show the login form controls: the text fields and labels.
 */

- (void) _showLoginForm
{
	_usernameLabel.hidden = NO;
	_usernameTextField.hidden = NO;
	_passwordLabel.hidden = NO;
	_passwordTextField.hidden = NO;
}

/**
 * Hide the status components: the status label and the progress spinner.
 */

- (void) _hideStatus
{
	_activityIndicatorView.hidden = YES;
	[_activityIndicatorView stopAnimating];
	_statusLabel.hidden = YES;
}

/**
 * Show the status components: the status label and the progress spinner.
 */

- (void) _showStatus
{
	_activityIndicatorView.hidden = NO;
	[_activityIndicatorView startAnimating];
	_statusLabel.hidden = NO;
}

#pragma mark -

- (void) viewDidLoad
{
	[self _hideStatus];

	// Give the container view round corners

	_containerView.layer.cornerRadius = 15;

	// Set the title of this view controller
	
	self.title = @"Login";
	
	// Add a login button to the navigation bar
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Login" style: UIBarButtonItemStyleDone target: self action: @selector(login)];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	// Register callbacks for when the text fields change so that we can update the button status
	
	[_usernameTextField addTarget: self action: @selector(updateLoginButton) forControlEvents: UIControlEventEditingChanged];	
	[_passwordTextField addTarget: self action: @selector(updateLoginButton) forControlEvents: UIControlEventEditingChanged];
	
	// Make ourself the delegate for the text fields so that we receive the textFieldShouldReturn: message
	
	_usernameTextField.delegate = self;
	_passwordTextField.delegate = self;
}

- (void) viewDidAppear:(BOOL)animated
{
	[_usernameTextField becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated
{
	// If we still have a request running, cancel it

	if (_request != nil) {
		[_request clearDelegatesAndCancel];
		[_request release];
		_request = nil;
	}
}

#pragma mark -

- (void) requestFinished: (ASIHTTPRequest*) request
{
	// Hide the progress indicator and show the form again

	self.navigationItem.rightBarButtonItem.enabled = YES;
	[self _showLoginForm];
	[self _hideStatus];
	
	// If our request was not succesful then call the delegate's failure methods. Otherwise call it's success
	// method and pass it the credentials.
	
	if (request.responseStatusCode != 200) {
		[_delegate loginViewController:self didFailWithError: nil];
	} else {
		NSDictionary* response = [[request responseString] JSONValue];
		if ([response objectForKey: @"error"] != nil) {
			NSString* error = [response objectForKey: @"error"];
			[_delegate loginViewController: self didFailWithServerError: error];
			_passwordTextField.text = @"";
			[_passwordTextField becomeFirstResponder];
		} else {
			NSString* key = [response objectForKey: @"key"];
			[_delegate loginViewController: self didSucceedWithUsername: _usernameTextField.text password: _passwordTextField.text sessionKey: key];
		}
	}

	// Get rid of the request
	
	[_request release];
	_request = nil;
}

- (void) requestFailed: (ASIHTTPRequest*) request
{
	// Hide the progress indicator and show the form again

	self.navigationItem.rightBarButtonItem.enabled = YES;
	[self _showLoginForm];
	[self _hideStatus];

	// Call the delegate's failure method
	
	[_delegate loginViewController: self didFailWithError: request.error];
	
	// Get rid of the request

	[_request release];
	_request = nil;
}

#pragma mark -

/**
 * Action method that is called when the user hits the Login button. We hide the login form, show the
 * progress spinner and then start a HTTP request.
 */

- (IBAction) login
{
	[self _hideLoginForm];
	[self _showStatus];
	
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSURL* url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/login", [defaults objectForKey: @"BankServiceURL"]]];
	
	_request = [[ASIFormDataRequest requestWithURL: url] retain];
	[_request setPostValue: _usernameTextField.text forKey: @"username"];
	[_request setPostValue: _passwordTextField.text forKey: @"password"];
	[_request setDelegate: self];
	[_request startAsynchronous];	
}

#pragma mark -

/**
 * Delegate method of the UITextField that is called every time when the user submits the text field
 * by pressing the return button. We use this method to make the next text field active or to start
 * the login process.
 */

- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
	if (textField == _usernameTextField) {
		[_passwordTextField becomeFirstResponder];
		return YES;
	}
	
	if (textField == _passwordTextField) {
		if ([_usernameTextField.text length] != 0 && [_passwordTextField.text length] != 0) {
			[_passwordTextField resignFirstResponder];
			[self login];
			return YES;
		}
	}
	
	return NO;
}

/**
 * Called every time one of the text fields changes. We use this to enable or disable the Login
 * button. We can only login if both fields have been filled in.
 */

- (void) updateLoginButton
{
	self.navigationItem.rightBarButtonItem.enabled = ([_usernameTextField.text length] != 0 && [_passwordTextField.text length] != 0);
}

@end