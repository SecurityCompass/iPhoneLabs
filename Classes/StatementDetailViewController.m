//  StatementDetailViewController.m

#import "Constants.h"
#import "Crypto.h"
#import "StatementDetailViewController.h"

@implementation StatementDetailViewController

@synthesize  webView = _webView;

- (id) initWithStatementName: (NSString*) statementName
{
    if ((self = self = [super initWithNibName: nil bundle: nil]) != nil) {
		_statementName = [statementName retain];
    }
    return self;
}

- (void)dealloc
{
	[_statementName release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
	// Disable data detectors otherwise bank account numbers are recognized as phone numbers

	_webView.dataDetectorTypes = UIDataDetectorTypeNone;

	// Decrypt the statement and iv

	NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
	NSString* path = [documentsDirectory stringByAppendingPathComponent: _statementName];
	
	NSData* encryptedStatement = [NSData dataWithContentsOfFile: [path stringByAppendingPathExtension: @"statement"]];
	NSData* encryptedStatementIV = [NSData dataWithContentsOfFile: [path stringByAppendingPathExtension: @"iv"]];
	
	if (encryptedStatement != nil && encryptedStatementIV != nil) {
		NSString* content = BankDecryptString(encryptedStatement, [kSecretEncryptionKey dataUsingEncoding: NSUTF8StringEncoding], encryptedStatementIV);
		if (content != nil) {	
			[_webView loadHTMLString: content baseURL: nil];
		} else {
			[_webView loadHTMLString: @"Decryption failure" baseURL: nil];
		}
	} else {
		[_webView loadHTMLString: @"Not found" baseURL: nil];
	}
}

@end