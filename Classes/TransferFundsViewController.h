// TransferFundsViewController.h

#import <UIKit/UIKit.h>
#import "SelectAccountViewController.h"

@interface TransferFundsViewController : UITableViewController <SelectAccountViewControllerDelegate> {
  @private
	NSUInteger _selectedRow;
	NSArray* _accountNames;
	NSString* _fromAccount;
	NSString* _toAccount;
}

@end