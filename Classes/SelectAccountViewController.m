// SelectAccountViewController.m

#import "SelectAccountViewController.h"

@implementation SelectAccountViewController

- (id) initWithAccountNames: (NSArray*) accountNames delegate: (id<SelectAccountViewControllerDelegate>) delegate
{
	if ((self = [super initWithStyle: UITableViewStyleGrouped]) != nil) {
		_accountNames = [accountNames retain];
		_delegate = delegate;
	}
	return self;
}

- (void) dealloc
{
	[_accountNames release];
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
	return [_accountNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [_accountNames objectAtIndex: indexPath.row];
    
    return cell;
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_delegate selectAccountViewController: self didSelectAccount: [_accountNames objectAtIndex: indexPath.row]];
}

#pragma mark -

- (void) cancel
{
	[_delegate selectAccountViewControllerDidCancel: self];
}

@end