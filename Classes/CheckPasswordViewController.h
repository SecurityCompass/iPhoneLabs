// CheckPasswordViewController.h

#import <UIKit/UIKit.h>

@class CheckPasswordViewController;

@protocol CheckPasswordViewControllerDelegate <NSObject>
- (BOOL) checkPasswordViewController: (CheckPasswordViewController*) vc didEnterPassword: (NSString*) password;
@end

@interface CheckPasswordViewController : UIViewController <UITextFieldDelegate> {
  @private
	UITextField* _passwordTextField;
	UIView* _containerView;
  @private
    id<CheckPasswordViewControllerDelegate> _delegate;
}

@property (nonatomic,assign) IBOutlet UIView* containerView;
@property (nonatomic,assign) IBOutlet UITextField* passwordTextField;
@property (nonatomic,assign) id<CheckPasswordViewControllerDelegate> delegate;

@end
