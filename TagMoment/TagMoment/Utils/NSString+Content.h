
#import <Foundation/Foundation.h>

@interface NSString (Content)

+ (BOOL)emptyOrWhiteSpace:(NSString*) string;
- (BOOL)hasEmojis;
@end
