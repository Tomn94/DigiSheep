//
//  Data.h
//  DigiSheep
//
//  Created by Tomn on 18/01/2016.
//  Copyright © 2016 Tomn. All rights reserved.
//

@import Foundation;
@import UIKit;

#define URL_LOGIN @"http://217.199.187.59/francoisle.fr/lacommande/api/digisheep/login.php"

@interface Data : NSObject

+ (Data *) sharedData;
+ (NSString *) encoderPourURL:(NSString *)url;

@property (strong, nonatomic) NSString *login;
@property (strong, nonatomic) NSString *pass;
@property (strong, nonatomic) NSString *sellEvent;

- (void) updLoadingActivity:(BOOL)visible;

@end
