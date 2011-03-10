// CheckPasswordViewController.m

#import <QuartzCore/QuartzCore.h>
#import "CheckPasswordViewController.h"

@implementation CheckPasswordViewController

@synthesize containerView = _containerView;
@synthesize passwordTextField = _passwordTextField;
@synthesize delegate = _delegate;

/**
 * When the view is loaded. We configure all the components and setup callbacks.
 */

- (void) viewDidLoad
{
	self.title = @"Unlock";

	_containerView.layer.cornerRadius = 15;
	
	// Add the 'Unlock' button to the navigation bar
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Unlock" style: UIBarButtonItemStyleDone target: self action: @selector(unlock)];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	// Register a callback for when the text field changes so that we can update the button status
	[_passwordTextField addTarget: self action: @selector(updateUnlockButton) forControlEvents: UIControlEventEditingChanged];	
	
	// Make ourself the delegate for the text field so that we receive the textFieldShouldReturn: message
	_passwordTextField.delegate = self;
}

/**
 * When the view appeared on screen we make the password text field the first responder. This
 * will result in the keyboard popping up.
 */

- (void) viewDidAppear:(BOOL)animated
{
	[_passwordTextField becomeFirstResponder];
}

/**
 * Action method that is called when the user presses the Unlock button. All we do is give the
 * delegate a change to look at the password and take the appropriate action.
 */

- (IBAction) unlock
{
	[_delegate checkPasswordViewController: self didEnterPassword: _passwordTextField.text];
}

/**
 * Delegate method of the UITextField that is called every time when the user submits the text field
 * by pressing the return button. We use this method to inform the delegate that the password has
 * been entered and submitted.
 */

- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
	if (textField == _passwordTextField) {		
		if ([_passwordTextField.text length] != 0) {
			[_delegate checkPasswordViewController: self didEnterPassword: _passwordTextField.text];
			return YES;
		}
	}
	return NO;
}

/**
 * Called every time the text field changes. We use this to enable or disable the Unlock
 * button. We can only submit the form when a password has been entered.
 */

- (void) updateUnlockButton
{
	self.navigationItem.rightBarButtonItem.enabled = ([_passwordTextField.text length] != 0);
}

@end
