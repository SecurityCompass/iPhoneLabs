//  StatementDetailViewController.m

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
	//_webView.delegate = self;

	NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
	NSString* statementPath = [documentsDirectory stringByAppendingPathComponent: _statementName];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath: statementPath]) {
		NSString* content = [NSString stringWithContentsOfFile: statementPath encoding: NSUTF8StringEncoding error: nil];
		[_webView loadHTMLString: content baseURL: nil];
	} else {
		[_webView loadHTMLString: @"Not found" baseURL: nil];
	}
}

@end