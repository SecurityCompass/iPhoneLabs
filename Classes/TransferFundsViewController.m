//  TransferFundsViewController.m

#import "TransferFundsViewController.h"
#import "SelectAccountViewController.h"

@implementation TransferFundsViewController

- (id) init
{
	if ((self = [super initWithStyle: UITableViewStyleGrouped]) != nil) {
		_accountNames = [[NSArray arrayWithObjects: @"Savings", @"Checking", @"Credit", nil] retain];
		_fromAccount = [[_accountNames objectAtIndex: 0] retain];
		_toAccount = [[_accountNames objectAtIndex: 1] retain];
	}
	return self;
}

- (void) dealloc
{
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
			}
		}
	}
    
	//
	
	if (indexPath.section == 0)
	{
		switch (indexPath.row)
		{
			case 0:
				cell.textLabel.text = @"Amount:";
				break;
			case 1:
				cell.textLabel.text = [NSString stringWithFormat: @"From: %@", _fromAccount];
				break;
			case 2:
				cell.textLabel.text = [NSString stringWithFormat: @"To: %@", _toAccount];
				break;
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
		SelectAccountViewController* selectAccountViewController = [[[SelectAccountViewController alloc] initWithAccountNames: _accountNames delegate: self] autorelease];
		[self.navigationController pushViewController: selectAccountViewController animated: YES];
	}

	[tableView deselectRowAtIndexPath: indexPath animated: NO];
}

#pragma mark -

- (void) selectAccountViewControllerDidCancel:(SelectAccountViewController *)vc
{
	[self.navigationController popViewControllerAnimated: YES];
}

- (void) selectAccountViewController:(SelectAccountViewController *)vc didSelectAccount:(NSString*)account
{
	if (_selectedRow == 1) {
		[_fromAccount release];
		_fromAccount = [account retain];
	} else {
		[_toAccount release];
		_toAccount = [account retain];
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
	[self.navigationController popViewControllerAnimated: YES];
}

@end

