/*
 @author: ideawu
 @link: https://github.com/ideawu/Objective-C-RSA
*/

#import <Foundation/Foundation.h>

@interface UCRSA : NSObject

// return hex-string encoded string
+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey;
// return raw data
+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey;
@end
