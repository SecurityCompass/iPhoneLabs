//  SetupPasswordViewController.h

#import <UIKit/UIKit.h>

@class SetupPasswordViewController;

@protocol SetupPasswordViewControllerDelegate <NSObject>
- (void) setupPasswordViewController: (SetupPasswordViewController*) vc didSetupPassword: (NSString*) password;
@end

@interface SetupPasswordViewController : UIViewController <UITextFieldDelegate> {
  @private
	UIView* _containerView;
	UITextField* _password1TextField;
	UITextField* _password2TextField;
  @private
    id<SetupPasswordViewControllerDelegate> _delegate;
}

@property (nonatomic,assign) IBOutlet UIView* containerView;
@property (nonatomic,assign) IBOutlet UITextField* password1TextField;
@property (nonatomic,assign) IBOutlet UITextField* password2TextField;

@property (nonatomic,assign) id<SetupPasswordViewControllerDelegate> delegate;

@end