//  Account.m

#import "Account.h"

@implementation Account

@synthesize number = _number;
@synthesize type = _type;
@synthesize balance = _balance;

- (id) initWithNumber: (NSString*) number type: (NSString*) type balance: (NSString*) balance
{
	if ((self = [super init]) != nil) {
		_number = [number retain];
		_type = [type retain];
		_balance = [balance retain];
	}
	return self;
}

- (void) dealloc
{
	[_number release];
	[_type release];
	[_balance release];
	[super dealloc];
}

- (NSString*) name
{
	return [_type capitalizedString];
}

@end
