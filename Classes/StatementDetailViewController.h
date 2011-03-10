// StatementDetailViewController.h

#import <UIKit/UIKit.h>

@interface StatementDetailViewController : UIViewController {
  @private
    NSString* _statementName;
  @private
    UIWebView* _webView;
}

@property (nonatomic,assign) IBOutlet UIWebView* webView;

- (id) initWithStatementName: (NSString*) statementName;

@end
