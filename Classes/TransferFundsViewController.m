//  TransferFundsViewController.m

#import "Account.h"
#import "Networking.h"
#import "Utilities.h"
#import "TransferFundsViewController.h"
#import "SelectAccountViewController.h"

@implementation TransferFundsViewController

- (id) init
{
	if ((self = [super initWithStyle: UITableViewStyleGrouped]) != nil) {
		_fromAccountIndex = 0;
		_toAccountIndex = 1;
	}
	return self;
}

- (void) dealloc
{
	[_accounts release];
	[super dealloc];
}

#pragma mark -

- (void) viewDidLoad
{
	self.title = @"Transfer";
	self.tableView.scrollEnabled = NO;

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Transfer" style: UIBarButtonItemStyleDone
		target: self action: @selector(transfer)];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	// Grab the accounts from the server. This is blocking. In a more real-world application, this network call would
	// be asynchronous. For the sake of simplicity we simply use synchronous requests here.
	
	NSError* error;
	NSString* applicationError;

	NSArray* accounts = BankGetAccounts(&error, &applicationError);
	if (accounts != nil) {
		_accounts = [accounts retain];
	}
}

#pragma mark -

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
	return 1;
}


- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;

	if (indexPath.section == 0)
	{
		if (indexPath.row == 0)
		{
			static NSString *CellIdentifier = @"AmountCell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

				UITextField* textField = [[[UITextField alloc] initWithFrame: CGRectMake(100, 12, 160, 32)] autorelease];
				textField.tag = 1;
				textField.placeholder = @"Transfer Amount";
				textField.font = [UIFont systemFontOfSize: 18.0];
				textField.keyboardType = UIKeyboardTypeDefault;
				[textField addTarget: self action: @selector(updateTransferButton:) forControlEvents: UIControlEventEditingChanged];	
				[cell addSubview: textField];
			}
		}
		else
		{
			static NSString *CellIdentifier = @"AccountCell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				
				UILabel* label = [[[UILabel alloc] initWithFrame: CGRectMake(180, 9, 100, 24)] autorelease];
				label.font = [UIFont boldSystemFontOfSize: 17.0];
				label.textAlignment = UITextAlignmentRight;
				label.tag = 1;
				[cell addSubview: label];
			}
		}
	}
    
	//
	
	if (indexPath.section == 0)
	{
		switch (indexPath.row)
		{
			case 0: {
				cell.textLabel.text = @"Amount:";
				break;
			}
			case 1: {
				Account* account = [_accounts objectAtIndex: _fromAccountIndex];
				cell.textLabel.text = [NSString stringWithFormat: @"From %@ (%@)", account.name, [account.number substringFromIndex: 5]];
				UILabel* balanceLabel = (UILabel*) [cell viewWithTag: 1];
				balanceLabel.text = [NSString stringWithFormat: @"$%@", account.balance];
				break;
			}
			case 2: {
				Account* account = [_accounts objectAtIndex: _toAccountIndex];
				cell.textLabel.text = [NSString stringWithFormat: @"To %@ (%@)", account.name, [account.number substringFromIndex: 5]];
				UILabel* balanceLabel = (UILabel*) [cell viewWithTag: 1];
				balanceLabel.text = [NSString stringWithFormat: @"$%@", account.balance];
				break;
			}
		}
	}
    
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0) {
		UITextField* textField = (UITextField*) [cell viewWithTag: 1];
		[textField becomeFirstResponder];
	}
}

#pragma mark -

- (NSIndexPath*) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0) {
		return nil;
	} else {
		return indexPath;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 1 || indexPath.row == 2) {
		_selectedRow = indexPath.row;
		SelectAccountViewController* selectAccountViewController = [[[SelectAccountViewController alloc] initWithAccounts: _accounts delegate: self] autorelease];
		[self.navigationController pushViewController: selectAccountViewController animated: YES];
	}

	[tableView deselectRowAtIndexPath: indexPath animated: NO];
}

#pragma mark -

- (void) selectAccountViewControllerDidCancel:(SelectAccountViewController *)vc
{
	[self.navigationController popViewControllerAnimated: YES];
}

- (void) selectAccountViewController: (SelectAccountViewController*) vc didSelectAccountIndex: (NSUInteger) accountIndex
{
	if (_selectedRow == 1) {
		_fromAccountIndex = accountIndex;
	} else if (_selectedRow == 2) {
		_toAccountIndex = accountIndex;
	}

	[self.tableView reloadData];
	[self.navigationController popViewControllerAnimated: YES];
}

#pragma mark -

- (void) updateTransferButton: (UITextField*) textField
{
	self.navigationItem.rightBarButtonItem.enabled = ([textField.text length] != 0);
}

#pragma mark -

- (void) transfer
{
	NSError* error = nil;
	NSString* applicationError = nil;
	
	UITableViewCell* cell = [self.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0]];
	UITextField* textField = (UITextField*) [cell viewWithTag: 1];

	Account* fromAccount = [_accounts objectAtIndex: _fromAccountIndex];
	Account* toAccount = [_accounts objectAtIndex: _toAccountIndex];
	NSString* amount = textField.text;

	if (BankTransferFunds(fromAccount.number, toAccount.number, amount, &error, &applicationError) == NO) {
		if (error != nil) {
			BankDisplayErrorAlertView(error, nil);
		}
		else if (applicationError != nil) {
			BankDisplayApplicationErrorAlertView(applicationError, nil);
		}
	} else {
		[self.navigationController popViewControllerAnimated: YES];
	}
}

@end

	