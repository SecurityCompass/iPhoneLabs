// StatementsViewController.m

#import "Networking.h"
#import "StatementDetailViewController.h"
#import "StatementsViewController.h"

@implementation StatementsViewController

- (void) saveStatement: (NSString*) statement
{
	NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
	NSString* path = [[documentsDirectory stringByAppendingPathComponent: @"Statement"] stringByAppendingPathExtension: @"statement"];
	[statement writeToFile: path atomically: YES encoding: NSUTF8StringEncoding error: nil];
}

- (void) scanStatements
{
	NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
	NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: documentsDirectory error: nil];
	
	[_statements release];
	_statements = nil;
	
	_statements = [[files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.statement'"]] retain];
}

- (void) viewDidLoad
{
	// Look for .statement files in the Documents directory

	[self scanStatements];
		
	// If we have no statements then we download the default one
	
	if ([_statements count] == 0)
	{
		NSError* error = nil;
		NSString* applicationError = nil;
		
		NSString* statement = BankDownloadStatement(&error, &applicationError);
		if (statement != nil) {
			[self saveStatement: statement];
		}

		// Update the list of known statements

		[self scanStatements];
	}
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
    
    cell.textLabel.text = [_statements objectAtIndex: indexPath.row];
    
    return cell;
}

#pragma mark -

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	StatementDetailViewController* vc= [[[StatementDetailViewController alloc] initWithStatementName: [_statements objectAtIndex: indexPath.row]] autorelease];
	[self.navigationController pushViewController: vc animated: YES];
}

@end
