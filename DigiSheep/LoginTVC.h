//
//  LoginTVC.h
//  DigiSheep
//
//  Created by Tomn on 18/01/2016.
//  Copyright © 2016 Tomn. All rights reserved.
//

@import UIKit;

@interface LoginTVC : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *idField;
@property (weak, nonatomic) IBOutlet UITextField *passField;

- (void) connexion;

@end