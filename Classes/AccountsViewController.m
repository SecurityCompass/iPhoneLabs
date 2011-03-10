// AccountsViewController.m

#import "AccountsViewController.h"
#import "JSON.h"
#import "SessionManager.h"
#import "Constants.h"
#import "Utilities.h"
#import "Networking.h"
#import "BankAppDelegate.h"
#import "ASIFormDataRequest.h"

@implementation AccountsViewController

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self.navigationController popViewControllerAnimated: YES];
}

#pragma mark -
#pragma mark View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];

	// Set the title of this view controller
	
	self.title = @"Accounts";
	
	// Set the cell height globally

	self.tableView.rowHeight = 72;
}

- (void) viewDidAppear: (BOOL) animated
{
	NSError* error = nil;
	NSString* applicationError = nil;

	NSArray* accounts = BankGetAccounts(&error, &applicationError);
	if (accounts != nil) {
		_accounts = [accounts retain];
		[self.tableView reloadData];
	} else {
		if (error != nil) {
			BankDisplayErrorAlertView(error, nil);
		}
		else if (applicationError != nil) {
			BankDisplayApplicationErrorAlertView(applicationError, nil);
		}
	}
}

#pragma mark -

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
	// Try to get a previously used cell. If there is none then we create a new one
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		UILabel* nameLabel = [[[UILabel alloc] initWithFrame: CGRectMake(10, 20, 200, 28)] autorelease];
		nameLabel.tag = 1;
		nameLabel.font = [UIFont boldSystemFontOfSize: 24];
		[cell addSubview: nameLabel];

		UILabel* accountLabel = [[[UILabel alloc] initWithFrame: CGRectMake(10, 50, 200, 16)] autorelease];
		accountLabel.tag = 2;
		accountLabel.font = [UIFont systemFontOfSize: 12];
		accountLabel.textColor = [UIColor grayColor];
		[cell addSubview: accountLabel];
		
		UILabel* amountLabel = [[[UILabel alloc] initWithFrame: CGRectMake(180, 20, 130, 28)] autorelease];
		amountLabel.tag = 3;
		amountLabel.font = [UIFont boldSystemFontOfSize: 24];
		amountLabel.textAlignment = UITextAlignmentRight;
		[cell addSubview: amountLabel];
	}

	// Configure the cell for the account

	NSDictionary* account = [_accounts objectAtIndex: indexPath.row];

	UILabel* nameLabel = (UILabel*) [cell viewWithTag: 1];
	if (nameLabel != nil) {
		nameLabel.text = [account objectForKey: @"type"];
	}

	UILabel* accountLabel = (UILabel*) [cell viewWithTag: 2];
	if (accountLabel != nil) {
		accountLabel.text = [[account objectForKey: @"account_number"] description];
	}

	UILabel* balanceLabel = (UILabel*) [cell viewWithTag: 3];
	if (balanceLabel != nil) {
		balanceLabel.text = [account objectForKey: @"balance"];
	}
    
    return cell;
}

@end
