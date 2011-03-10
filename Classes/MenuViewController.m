// MenuViewController.m

#import "MenuViewController.h"
#import "AccountsViewController.h"
#import "TransferFundsViewController.h"
#import "StatementsViewController.h"

@implementation MenuViewController

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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	static NSString* titles[3] = { @"Account Overview", @"Transfer Funds", @"View Statements" };
	cell.textLabel.text = titles[indexPath.row];
			    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath: indexPath animated: NO];

	UIViewController* vc = nil;
	
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

}

@end
