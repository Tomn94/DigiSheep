//
//  Data.m
//  DigiSheep
//
//  Created by Tomn on 18/01/2016.
//  Copyright © 2016 Tomn. All rights reserved.
//

#import "Data.h"

@implementation Data

+ (Data *) sharedData {
    static Data *instance = nil;
    if (instance == nil) {
        
        static dispatch_once_t pred;        // Lock
        dispatch_once(&pred, ^{             // This code is called at most once per app
            instance = [[Data allocWithZone:NULL] init];
        });
        
    }
    return instance;
}

+ (NSString *) encoderPourURL:(NSString *)url
{
    if (url == nil)
        return url;
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[url UTF8String];
    NSInteger sourceLen = strlen((const char *)source);
    for (NSInteger i = 0; i < sourceLen; ++i)
    {
        const unsigned char thisChar = source[i];
        if (thisChar == ' ')
            [output appendString:@"+"];
        else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                 (thisChar >= 'a' && thisChar <= 'z') ||
                 (thisChar >= 'A' && thisChar <= 'Z') ||
                 (thisChar >= '0' && thisChar <= '9'))
            [output appendFormat:@"%c", thisChar];
        else
            [output appendFormat:@"%%%02X", thisChar];
    }
    return output;
}

- (void) updLoadingActivity:(BOOL)visible
{
    static NSInteger loadingCount = 0;
    
    if (visible)
        ++loadingCount;
    else
        --loadingCount;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(loadingCount > 0)];
}

@end
