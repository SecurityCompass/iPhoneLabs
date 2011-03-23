// MenuViewController.m

#import "MenuViewController.h"
#import "AccountsViewController.h"
#import "TransferFundsViewController.h"
#import "StatementsViewController.h"

@implementation MenuViewController

@synthesize  delegate = _delegate;

- (id) init
{
	if ((self = [super initWithStyle: UITableViewStyleGrouped]) != nil) {
	}
	return self;
}

- (void) viewDidLoad
{
	self.title = @"Menu";
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
	    return 3;
	} else {
		return 1;
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	if (indexPath.section == 0) {
		static NSString* titles[3] = { @"Account Overview", @"Transfer Funds", @"View Statements" };
		cell.textLabel.text = titles[indexPath.row];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		cell.textLabel.text = @"Reset Application";
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
			    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIViewController* vc = nil;
	
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				vc = [[AccountsViewController new] autorelease];
				break;
			case 1:
				vc = [[TransferFundsViewController new] autorelease];
				break;
			case 2:
				vc = [[StatementsViewController new] autorelease];
				break;
		}

		if (vc != nil) {
			[self.navigationController pushViewController: vc animated: YES];
		}
	} else {
		[tableView deselectRowAtIndexPath: indexPath animated: NO];
		UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle: @"Reset Application" message: @"Are you sure you want to reset the application and remove all it's data?"
			delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"OK", nil] autorelease];
		[alertView show];
	}
}

#pragma mark -

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		[_delegate menuViewControllerDidAskToResetApplication: self];
	}
}

@end
