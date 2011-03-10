// TransferFundsViewController.h

#import <UIKit/UIKit.h>
#import "SelectAccountViewController.h"

@interface TransferFundsViewController : UITableViewController <SelectAccountViewControllerDelegate> {
  @private
	NSUInteger _selectedRow;
	NSArray* _accounts;
	NSUInteger _fromAccountIndex;
	NSUInteger _toAccountIndex;
}

@end