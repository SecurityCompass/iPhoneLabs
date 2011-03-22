// Account.h

#import <Foundation/Foundation.h>

@interface Account : NSObject {
  @private
    NSString* _number;
	NSString* _type;
	NSString* _balance;
}

- (id) initWithNumber: (NSString*) number type: (NSString*) type balance: (NSString*) balance;

@property (nonatomic,readonly) NSString* number;
@property (nonatomic,readonly) NSString* type;
@property (nonatomic,readonly) NSString* balance;

@property (nonatomic,readonly) NSString* name;

@end
