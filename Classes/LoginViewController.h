// LoginViewController.h

#import <UIKit/UIKit.h>

@class LoginViewController;
@class ASIFormDataRequest;

@protocol LoginViewControllerDelegate
- (void) loginViewController: (LoginViewController*) loginViewController didSucceedWithUsername: (NSString*) username password: (NSString*) password sessionKey: (NSString*) sessionKey;
- (void) loginViewController: (LoginViewController*) loginViewController didFailWithServerError: (NSString*) applicationError;
- (void) loginViewController: (LoginViewController*) loginViewController didFailWithError: (NSError*) error;
@end


@interface LoginViewController : UIViewController <UITextFieldDelegate> {
  @private
	IBOutlet UIView* _containerView;
	IBOutlet UILabel* _usernameLabel;
	IBOutlet UITextField* _usernameTextField;
	IBOutlet UILabel* _passwordLabel;
	IBOutlet UITextField* _passwordTextField;
	IBOutlet UILabel* _statusLabel;
	IBOutlet UIActivityIndicatorView* _activityIndicatorView;
  @private
    id<LoginViewControllerDelegate> _delegate;
  @private
    ASIFormDataRequest* _request;
}

@property (nonatomic,assign) id<LoginViewControllerDelegate> delegate;

- (IBAction) login;

@end