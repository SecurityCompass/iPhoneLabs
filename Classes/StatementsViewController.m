// StatementsViewController.m

#import "Constants.h"
#import "Networking.h"
#import "Crypto.h"
#import "StatementDetailViewController.h"
#import "StatementsViewController.h"

@implementation StatementsViewController

- (void) saveStatement: (NSString*) statement
{
	// Encrypt the statement with the secret key
	
	NSData* encryptedStatementIV = BankGenerateRandomIV();
	NSData* encryptedStatement = BankEncryptString(statement, [kSecretEncryptionKey dataUsingEncoding: NSUTF8StringEncoding], encryptedStatementIV);

	// Write the statement and iv to separate files

	NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];

	NSString* file = [NSString stringWithFormat: @"%u", (unsigned long) [[NSDate date] timeIntervalSince1970]];
	NSString* path = [documentsDirectory stringByAppendingPathComponent: file];
	
	[encryptedStatement writeToFile: [path stringByAppendingPathExtension: @"statement"] atomically: YES];
	[encryptedStatementIV writeToFile: [path stringByAppendingPathExtension: @"iv"] atomically: YES];
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
	NSString* name = [[_statements objectAtIndex: indexPath.row] stringByDeletingPathExtension];	
	StatementDetailViewController* vc = [[[StatementDetailViewController alloc] initWithStatementName: name] autorelease];
	[self.navigationController pushViewController: vc animated: YES];
}

@end
