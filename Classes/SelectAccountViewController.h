// SelectAccountViewController.h

#import <UIKit/UIKit.h>

@class SelectAccountViewController;

@protocol SelectAccountViewControllerDelegate <NSObject>
- (void) selectAccountViewController: (SelectAccountViewController*) vc didSelectAccount: (NSString*) account;
- (void) selectAccountViewControllerDidCancel: (SelectAccountViewController*) vc;
@end

@interface SelectAccountViewController : UITableViewController {
  @private
	NSArray* _accountNames;
	id<SelectAccountViewControllerDelegate> _delegate;
}

- (id) initWithAccountNames: (NSArray*) accountNames delegate: (id<SelectAccountViewControllerDelegate>) delegate;

@end