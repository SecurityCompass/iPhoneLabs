//  MenuViewController.m

#import "MenuViewController.h"
#import "AccountsViewController.h"
#import "TransferFundsViewController.h"
#import "StatementsViewController.h"

@implementation MenuViewController

- (void) viewDidLoad
{
	self.title = @"Menu";
}

- (IBAction) accounts
{
	AccountsViewController* vc = [[AccountsViewController new] autorelease];
	if (vc != nil) {
		[self.navigationController pushViewController: vc animated: YES];
	}
}

- (IBAction) transfer
{
	TransferFundsViewController* vc = [[TransferFundsViewController new] autorelease];
	if (vc != nil) {
		[self.navigationController pushViewController: vc animated: YES];
	}
}

- (IBAction) statements
{
	StatementsViewController* vc = [[StatementsViewController new] autorelease];
	if (vc != nil) {
		[self.navigationController pushViewController: vc animated: YES];
	}
}

@end
