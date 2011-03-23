// BankAppDelegate.h

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "CheckPasswordViewController.h"
#import "SetupPasswordViewController.h"
#import "MenuViewController.h"

@interface BankAppDelegate : NSObject <UIApplicationDelegate, LoginViewControllerDelegate, CheckPasswordViewControllerDelegate, SetupPasswordViewControllerDelegate, MenuViewControllerDelegate> {
  @private
    UIWindow* _window;
	UINavigationController* _navigationController;
  @private
    NSString* _username;
	NSString* _password;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
