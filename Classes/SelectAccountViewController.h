// SelectAccountViewController.h

#import <UIKit/UIKit.h>

@class SelectAccountViewController;

@protocol SelectAccountViewControllerDelegate <NSObject>
- (void) selectAccountViewController: (SelectAccountViewController*) vc didSelectAccountIndex: (NSUInteger) accountIndex;
- (void) selectAccountViewControllerDidCancel: (SelectAccountViewController*) vc;
@end

@interface SelectAccountViewController : UITableViewController {
  @private
	NSArray* _accounts;
	id<SelectAccountViewControllerDelegate> _delegate;
}

- (id) initWithAccounts: (NSArray*) accounts delegate: (id<SelectAccountViewControllerDelegate>) delegate;

@end