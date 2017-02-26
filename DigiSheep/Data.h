//
//  Data.h
//  DigiSheep
//
//  Created by Thomas Naudet on 18/01/2016.
//  Copyright © 2016 Thomas Naudet

//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.

//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/
//

@import Foundation;
@import UIKit;
#import <CommonCrypto/CommonHMAC.h>

#define URL_LOGIN @"https://web59.secure-secure.co.uk/francoisle.fr/api/digisheep/login"
#define URL_JSON  @"https://web59.secure-secure.co.uk/francoisle.fr/api/events/"
#define URL_NAVET @"https://web59.secure-secure.co.uk/francoisle.fr/api/digisheep/items"
#define URL_CHECK @"https://web59.secure-secure.co.uk/francoisle.fr/api/digisheep/check"
#define URL_SEND  @"https://web59.secure-secure.co.uk/francoisle.fr/api/digisheep/send"

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
