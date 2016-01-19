//
//  PeopleTVC.h
//  DigiSheep
//
//  Created by Tomn on 18/01/2016.
//  Copyright © 2016 Tomn. All rights reserved.
//

@import UIKit;
#import "Data.h"


@interface PeopleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *field;

@end


@interface PeopleTVC : UITableViewController <UITextFieldDelegate>
{
    BOOL chargement;
    NSString *selectionPlace;
}

- (IBAction) deconnexion:(id)sender;
- (IBAction) valider:(id)sender;
- (void) evaluerNavettes:(NSDictionary *)nav;

@end
