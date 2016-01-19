//
//  Data.h
//  DigiSheep
//
//  Created by Tomn on 18/01/2016.
//  Copyright © 2016 Tomn. All rights reserved.
//

@import Foundation;
@import UIKit;
#import <CommonCrypto/CommonHMAC.h>

#define URL_LOGIN @"http://217.199.187.59/francoisle.fr/lacommande/api/digisheep/login.php"
#define URL_JSON  @"http://79.170.44.147/eseonews.fr/jsondata/events_data/events.json?%d"
#define URL_NAVET @"http://217.199.187.59/francoisle.fr/lacommande/api/digisheep/items.php"

@interface Data : NSObject

+ (Data *) sharedData;
+ (NSString *) hashed_string:(NSString *)input;
+ (NSString *) encoderPourURL:(NSString *)url;

@property (strong, nonatomic) NSString *login;
@property (strong, nonatomic) NSString *pass;
@property (nonatomic) NSInteger sellEvent;
@property (strong, nonatomic) NSDictionary *JSON;

- (void) updLoadingActivity:(BOOL)visible;

@end
