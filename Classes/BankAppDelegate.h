// BankAppDelegate.h

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "CheckPasswordViewController.h"
#import "SetupPasswordViewController.h"

@interface BankAppDelegate : NSObject <UIApplicationDelegate, LoginViewControllerDelegate, CheckPasswordViewControllerDelegate, SetupPasswordViewControllerDelegate> {
  @private
    UIWindow* _window;
	UINavigationController* _navigationController;
  @private
    NSString* _masterPassword;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (void) login;

@end
