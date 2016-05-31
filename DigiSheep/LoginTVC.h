//
//  LoginTVC.h
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