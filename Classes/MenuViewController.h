// MenuViewController.h

#import <UIKit/UIKit.h>

@class MenuViewController;

@protocol MenuViewControllerDelegate <NSObject>
- (void) menuViewControllerDidAskToResetApplication: (MenuViewController*) menuViewController;
@end

@interface MenuViewController : UITableViewController <UIAlertViewDelegate> {
  @private
	id<MenuViewControllerDelegate> _delegate;
}

@property (nonatomic,assign) id<MenuViewControllerDelegate> delegate;

@end
