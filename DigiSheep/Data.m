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

+ (NSString *) hashed_string:(NSString *)input
{
    const char *s = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, (unsigned int)keyData.length, digest);
    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash=[out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
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

- (void) sendResa:(NSDictionary *)d
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession              *defaultSession      = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                                   delegate:nil
                                                                              delegateQueue:[NSOperationQueue mainQueue]];
    
    NSString *nom    = [[d[@"nom"] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSString *date   = [[d[@"date"] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSString *ecole  = [[d[@"ecole"] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSString *dataQR = [[d[@"qrcode"] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSString *body = [NSString stringWithFormat:@"login=%@&password=%@&idevent=%@&clientname=%@&clientbirth=%@&clientschool=%@&barcode=%@&type=%@",
                      [[Data sharedData] login], [[Data sharedData] pass], [Data encoderPourURL:d[@"idevent"]],
                      [Data encoderPourURL:nom], [Data encoderPourURL:date], [Data encoderPourURL:ecole],
                      [Data encoderPourURL:dataQR], @"QR_CODE"];
    if (d[@"navette"] != nil && d[@"navette"][@"idshuttle"] != nil)
        body = [body stringByAppendingString:[NSString stringWithFormat:@"&idshuttle=%ld",
                                              (long)[d[@"navette"][@"idshuttle"] integerValue]]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL_SEND]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:request
                                                       completionHandler:^(NSData *data, NSURLResponse *r, NSError *error)
                                      {
                                          [[Data sharedData] updLoadingActivity:NO];
                                          
                                          if (error == nil && data != nil)
                                          {
                                              NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:kNilOptions
                                                                                                     error:nil];
                                              if ([JSON[@"status"] integerValue] == 1)
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"retourResa" object:nil
                                                                                                    userInfo:@{ @"status": @1,
                                                                                                                @"nom"   : d[@"nom"] }];
                                              else
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"retourResa" object:nil userInfo:@{ @"status": JSON[@"status"], @"errMsg": JSON[@"cause"] }];
                                              
                                          }
                                          else
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"retourResa" object:nil
                                                                                                userInfo:@{ @"status": @(-10),
                                                                                                            @"errMsg": @"Impossible de se connecter à la base de données" }];
                                      }];
    [dataTask resume];
    [[Data sharedData] updLoadingActivity:YES];
}

@end
