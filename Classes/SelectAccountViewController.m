// SelectAccountViewController.m

#import "Account.h"
#import "SelectAccountViewController.h"

@implementation SelectAccountViewController

- (id) initWithAccounts: (NSArray*) accounts delegate: (id<SelectAccountViewControllerDelegate>) delegate
{
	if ((self = [super initWithStyle: UITableViewStyleGrouped]) != nil) {
		_accounts = [accounts retain];
		_delegate = delegate;
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
	self.title = @"Select Account";	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
		target: self action: @selector(cancel)] autorelease];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		UILabel* label = [[[UILabel alloc] initWithFrame: CGRectMake(180, 9, 100, 24)] autorelease];
		label.font = [UIFont boldSystemFontOfSize: 17.0];
		label.textAlignment = UITextAlignmentRight;
		label.tag = 1;
		[cell addSubview: label];
    }
    
	Account* account = [_accounts objectAtIndex: indexPath.row];

    cell.textLabel.text = [NSString stringWithFormat: @"%@ (%@)", account.name, [account.number substringFromIndex: 5]];

	UILabel* balanceLabel = (UILabel*) [cell viewWithTag: 1];
	balanceLabel.text = [NSString stringWithFormat: @"$%@", account.balance];
    
    return cell;
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_delegate selectAccountViewController: self didSelectAccountIndex: indexPath.row];
}

#pragma mark -

- (void) cancel
{
	[_delegate selectAccountViewControllerDidCancel: self];
}

@end