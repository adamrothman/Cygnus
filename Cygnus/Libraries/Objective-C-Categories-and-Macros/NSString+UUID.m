#import "NSString+UUID.h"


#pragma mark Class Definition

@implementation NSString (UUID)


#pragma mark -
#pragma mark Public Methods

+ (NSString *)generateUUID
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    return uuidString;
}


@end // @implementation NSString (UUID)