// AccountsViewController.m

#import "AccountsViewController.h"
#import "JSON.h"
#import "SessionManager.h"
#import "Constants.h"
#import "Utilities.h"
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
	
	// We keep the accounts in an array

	_accounts = [NSMutableArray new];
}

- (void) updateSession
{
	NSURL* url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/login", kBankServiceURL]];
	NSLog(@"Requesting %@", [url absoluteString]);

	ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL: url];
	[request setPostValue: [[NSUserDefaults standardUserDefaults] objectForKey: @"Username"] forKey: @"username"];
	[request setPostValue: [[NSUserDefaults standardUserDefaults] objectForKey: @"Password"] forKey: @"password"];
	[request startSynchronous];
	
	NSDictionary* dictionary = [[request responseString] JSONValue];

	SessionManager* sessionManager = [SessionManager sharedSessionManager];
	sessionManager.sessionKey = [dictionary objectForKey: @"key"];
}

- (void) updateData
{
	// If we do not have a session then login to get the session key
	
	SessionManager* sessionManager = [SessionManager sharedSessionManager];
	if (sessionManager.sessionKey == nil) {
		[self updateSession];
	}
	
	// Request the accounts

	NSURL* url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/accounts?session_key=%@", kBankServiceURL,
		BankEscapeQueryParameter(sessionManager.sessionKey)]];
	
	NSLog(@"Requesting %@", [url absoluteString]);
	
	// Start the HTTP request in the background
	
	ASIHTTPRequest* request= [ASIHTTPRequest requestWithURL: url];
	[request startSynchronous];
	
	if (request.error != nil) {
		BankDisplayErrorAlertView(request.error, self);
	} else {
		NSString *responseString = [request responseString];
		NSLog(@"Response = %@", responseString);

		if (request.responseStatusCode != 200) {
			BankDisplayAlertView(@"The server returned an unexpected response", self);
		} else {
			id response = [[request responseString] JSONValue];
			if ([response isKindOfClass: [NSDictionary class]]) {
				NSDictionary* dictionary = response;
				if ([dictionary objectForKey: @"error"] != nil) {
					NSString* error = [dictionary objectForKey: @"error"];
					if ([error isEqualToString: @"E2"]) {
						[self updateSession];
						[self updateData];
					} else {
						BankDisplayApplicationErrorAlertView(error, self);
					}
				}
			} else {
				[_accounts addObjectsFromArray: response];
				[self.tableView reloadData];
			}
		}
	}
}

- (void) viewWillAppear:(BOOL)animated
{
	[self updateData];
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
