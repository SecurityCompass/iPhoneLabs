// SelectAccountViewController.m

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
    }
    
	NSDictionary* account = [_accounts objectAtIndex: indexPath.row];
    cell.textLabel.text = [account objectForKey: @"type"];
    
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