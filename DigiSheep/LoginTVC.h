//
//  LoginTVC.h
//  DigiSheep
//
//  Created by Tomn on 18/01/2016.
//  Copyright © 2016 Tomn. All rights reserved.
//

@import UIKit;
#import "Data.h"


@interface LoginVC : UIViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *updSpin;
@property (weak, nonatomic) IBOutlet UILabel *updTxt;

- (void) showText:(NSNotification *)notif;

@end


@interface LoginTVC : UITableViewController <UITextFieldDelegate>
{
    BOOL chargement;
}

@property (weak, nonatomic) IBOutlet UITextField *idField;
@property (weak, nonatomic) IBOutlet UITextField *passField;

- (void) connexion;

@end