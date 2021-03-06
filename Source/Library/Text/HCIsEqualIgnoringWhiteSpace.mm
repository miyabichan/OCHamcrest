//
//  OCHamcrest - HCIsEqualIgnoringWhiteSpace.mm
//  Copyright 2011 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

#import "HCIsEqualIgnoringWhiteSpace.h"

#import "HCDescription.h"
#import "HCRequireNonNilObject.h"
#import <cctype>
using namespace std;


namespace {

void removeTrailingSpace(NSMutableString *string)
{
    NSUInteger length = [string length];
    if (length > 0)
    {
        NSUInteger charIndex = length - 1;
        if (isspace([string characterAtIndex:charIndex]))
            [string deleteCharactersInRange:NSMakeRange(charIndex, 1)];
    }
}


NSMutableString *stripSpace(NSString *string)
{
    NSUInteger length = [string length];
    NSMutableString *result = [NSMutableString stringWithCapacity:length];
    bool lastWasSpace = true;
    for (NSUInteger charIndex = 0; charIndex < length; ++charIndex)
    {
        unichar character = [string characterAtIndex:charIndex];
        if (isspace(character))
        {
            if (!lastWasSpace)
                [result appendString:@" "];
            lastWasSpace = true;
        }
        else
        {
            [result appendFormat:@"%C", character];
            lastWasSpace = false;
        }
    }
        
    removeTrailingSpace(result);
    return result;
}

}   // namespace

//--------------------------------------------------------------------------------------------------

@implementation HCIsEqualIgnoringWhiteSpace

+ (id)isEqualIgnoringWhiteSpace:(NSString *)aString
{
    return [[[self alloc] initWithString:aString] autorelease];
}


- (id)initWithString:(NSString *)aString
{
    HCRequireNonNilObject(aString);
    
    self = [super init];
    if (self != nil)
    {
        originalString = [aString copy];
        strippedString = [stripSpace(aString) retain];
    }
    return self;
}


- (void)dealloc
{
    [strippedString release];
    [originalString release];
    
    [super dealloc];
}


- (BOOL)matches:(id)item
{
    if (![item isKindOfClass:[NSString class]])
        return NO;
    
    return [strippedString isEqualToString:stripSpace(item)];
}


- (void)describeTo:(id<HCDescription>)description
{
    [[description appendDescriptionOf:originalString]
                  appendText:@" ignoring whitespace"];
}

@end

//--------------------------------------------------------------------------------------------------

OBJC_EXPORT id<HCMatcher> HC_equalToIgnoringWhiteSpace(NSString *string)
{
    return [HCIsEqualIgnoringWhiteSpace isEqualIgnoringWhiteSpace:string];
}
