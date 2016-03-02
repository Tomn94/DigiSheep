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

#define URL_LOGIN @"https://web59.secure-secure.co.uk/francoisle.fr/lacommande/api/digisheep/login.php"
#define URL_JSON  @"https://web59.secure-secure.co.uk/francoisle.fr/eseonews/jsondata/events_data/events.json?%d"
#define URL_NAVET @"https://web59.secure-secure.co.uk/francoisle.fr/lacommande/api/digisheep/items.php"
#define URL_CHECK @"https://web59.secure-secure.co.uk/francoisle.fr/lacommande/api/digisheep/check.php"
#define URL_SEND  @"https://web59.secure-secure.co.uk/francoisle.fr/lacommande/api/digisheep/send.php"

@interface Data : NSObject

+ (Data *) sharedData;
+ (NSString *) hashed_string:(NSString *)input;
+ (NSString *) encoderPourURL:(NSString *)url;

@property (strong, nonatomic) NSString *login;
@property (strong, nonatomic) NSString *pass;
@property (nonatomic) NSInteger sellEvent;
@property (strong, nonatomic) NSDictionary *JSON;
@property (strong, nonatomic) NSString *subEvent;

- (void) updLoadingActivity:(BOOL)visible;
- (void) sendResa:(NSDictionary *)d;

@end
