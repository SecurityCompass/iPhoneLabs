// StatementsViewController.m

#import "Networking.h"
#import "StatementDetailViewController.h"
#import "StatementsViewController.h"

@implementation StatementsViewController

- (void) saveStatement: (NSString*) statement
{
	NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
	NSString* path = [[documentsDirectory stringByAppendingPathComponent:
		[NSString stringWithFormat: @"%u", (unsigned long) [[NSDate date] timeIntervalSince1970]]]
			stringByAppendingPathExtension: @"statement"];
	[statement writeToFile: path atomically: YES encoding: NSUTF8StringEncoding error: nil];
}

- (void) scanStatements
{
	[_statements release];
	_statements = nil;

	NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
	NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: documentsDirectory error: nil];

	_statements = [[files filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"self ENDSWITH '.statement'"]] retain];
	
	[self.tableView reloadData];
}

- (void) loadStatement
{
	NSError* error = nil;
	NSString* applicationError = nil;

	NSString* statement = BankDownloadStatement(&error, &applicationError);
	if (statement != nil) {
		[self saveStatement: statement];
	}
}

- (void) deleteStatements
{
	NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
	NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: documentsDirectory error: nil];
	
	for (NSString* file in files)
	{
		if ([[file pathExtension] isEqualToString: @"statement"])
		{
			NSString* path = [documentsDirectory stringByAppendingPathComponent: file];
			[[NSFileManager defaultManager] removeItemAtPath: path error: NULL];
		}
	}
	
}

- (void) clear
{
	[self deleteStatements];	
	[self scanStatements];
}

- (void) viewDidLoad
{
	// Add a login button to the navigation bar
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Clear" style: UIBarButtonItemStylePlain target: self action: @selector(clear)];

	// Add a statement and scan for all available downloaded statements

	[self loadStatement];
	[self scanStatements];
}

- (void) viewDidUnload
{
	[_statements release];
	_statements = nil;
}

#pragma mark -

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return [_statements count];
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	NSDateFormatter* formatter = [[NSDateFormatter new] autorelease];
	[formatter setDateStyle: NSDateFormatterMediumStyle];
	[formatter setTimeStyle: NSDateFormatterLongStyle];
	
	NSString* statementName = [_statements objectAtIndex: indexPath.row];
	NSString* timestamp = [statementName stringByDeletingPathExtension];
    cell.textLabel.text = [formatter stringFromDate: [NSDate dateWithTimeIntervalSince1970: [timestamp doubleValue]]];
    
    return cell;
}

#pragma mark -

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	StatementDetailViewController* vc= [[[StatementDetailViewController alloc] initWithStatementName: [_statements objectAtIndex: indexPath.row]] autorelease];
	[self.navigationController pushViewController: vc animated: YES];
}

@end
