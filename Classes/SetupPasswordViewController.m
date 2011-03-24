//  SetupPasswordViewController.m

#import "Crypto.h"
#import <QuartzCore/QuartzCore.h>
#import "SetupPasswordViewController.h"

@implementation SetupPasswordViewController

@synthesize containerView = _containerView;
@synthesize password1TextField = _password1TextField;
@synthesize password2TextField = _password2TextField;
@synthesize delegate = _delegate;

/**
 * When the view is loaded. We configure all the components and setup callbacks.
 */

- (void) viewDidLoad
{
	self.title = @"Setup Password";

	_containerView.layer.cornerRadius = 15;

	// Add the 'Done' button to the navigation bar
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Done" style: UIBarButtonItemStyleDone target: self action: @selector(done)];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	// Register a callback for when the text field changes so that we can update the button status
	[_password1TextField addTarget: self action: @selector(updateDoneButton) forControlEvents: UIControlEventEditingChanged];	
	[_password2TextField addTarget: self action: @selector(updateDoneButton) forControlEvents: UIControlEventEditingChanged];	
	
	// Make ourself the delegate for the text field so that we receive the textFieldShouldReturn: message
	_password1TextField.delegate = self;
	_password2TextField.delegate = self;
}

/**
 * When the view appeared on screen we make the password text field the first responder. This
 * will result in the keyboard popping up.
 */

- (void) viewDidAppear:(BOOL)animated
{
	[_password1TextField becomeFirstResponder];
}

/**
 * Action method that is called when the user presses the Unlock button. All we do is give the
 * delegate a change to look at the password and take the appropriate action.
 */

- (IBAction) done
{
	if (BankCheckPasswordStrength(_password1TextField.text)) {
		[_delegate setupPasswordViewController: self didSetupPassword: _password1TextField.text];
	} else {
		UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle: @"Password Problem" message: @"The supplied password is too weak. Use a password longer than N characters that has at least some numbers and letters in it."
			delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] autorelease];
		[alertView show];
	}
}

/**
 * Delegate method of the UITextField that is called every time when the user submits the text field
 * by pressing the return button. We use this method to inform the delegate that the password has
 * been entered and submitted.
 */

- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
	if (textField == _password1TextField) {		
		[_password2TextField becomeFirstResponder];
		return YES;
	}
	
	if (textField == _password2TextField) {
		if ([_password1TextField.text isEqualToString: _password2TextField.text]) {
			[self done];
			return YES;
		}
	}
	
	return NO;
}

/**
 * Called every time the text field changes. We use this to enable or disable the Unlock
 * button. We can only submit the form when a password has been entered.
 */

- (void) updateDoneButton
{
	self.navigationItem.rightBarButtonItem.enabled
		= ([_password1TextField.text length] != 0) && [_password1TextField.text isEqualToString: _password2TextField.text];
}

@end
