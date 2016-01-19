//
//  PeopleTVC.m
//  DigiSheep
//
//  Created by Tomn on 18/01/2016.
//  Copyright © 2016 Tomn. All rights reserved.
//

#import "PeopleTVC.h"

@implementation PeopleCell
@end


@implementation PeopleTVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = [[Data sharedData] JSON][@"titre"];
}

- (IBAction) deconnexion:(id)sender
{
    [[Data sharedData] setLogin:nil];
    [[Data sharedData] setPass:nil];
    [[Data sharedData] setSellEvent:-1];
    [[Data sharedData] setJSON:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) valider:(id)sender
{
    if (chargement)
        return;
    
    PeopleCell *cell1 = (PeopleCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    PeopleCell *cell2 = (PeopleCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    PeopleCell *cell3 = (PeopleCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    if ([cell1.field.text isEqualToString:@""] || [cell2.field.text isEqualToString:@""] || [cell3.field.text isEqualToString:@""])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Erreur"
                                                                       message:@"Remplissez tous les champs"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else if (![[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"(\\d{2})/(\\d{2})/(\\d{4})"] evaluateWithObject:cell2.field.text])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Erreur"
                                                                       message:@"Vérifiez le format de la date\n(21/01/2042)"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [cell2.field becomeFirstResponder];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if (selectionPlace == nil || [selectionPlace isEqualToString:@""])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Erreur"
                                                                       message:@"Sélectionnez un type de place"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession              *defaultSession      = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                                   delegate:nil
                                                                              delegateQueue:[NSOperationQueue mainQueue]];
    
    // CONNEXION À LA BDD NAVETTES
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL_NAVET]];
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:request
                                                       completionHandler:^(NSData *data, NSURLResponse *r, NSError *error)
                                      {
                                          [[Data sharedData] updLoadingActivity:NO];
                                          UIAlertController *alert = nil;
                                          
                                          if (error == nil && data != nil)
                                          {
                                              NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                              options:kNilOptions
                                                                                                error:nil];
                                              [self evaluerNavettes:JSON[0][@"event-navettes"]];
                                          }
                                          else
                                              alert = [UIAlertController alertControllerWithTitle:@"Erreur"
                                                                                          message:@"Impossible de se connecter à la base de données navettes"
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                                          if (alert != nil)
                                          {
                                              chargement = NO;
                                              [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                                              [self presentViewController:alert animated:YES completion:nil];
                                          }
                                      }];
    [dataTask resume];
    [[Data sharedData] updLoadingActivity:YES];
}

- (void) evaluerNavettes:(NSDictionary *)nav
{
    NSInteger nbrPlacesRest = 0;
    BOOL hasNavettes = NO;
    for (NSDictionary *navette in nav)
    {
        if ([selectionPlace isEqualToString:navette[@"idevent"]])
        {
            nbrPlacesRest += [navette[@"restseats"] integerValue];
            hasNavettes = YES;
        }
    }
    
    if (hasNavettes)
    {
        NSLog(@"Navettes");
    }
    else
    {
        NSLog(@"PAS navettes");
    }
    
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView
  numberOfRowsInSection:(NSInteger)section
{
    if (section)
        return [[[Data sharedData] JSON][@"tickets"] count];
    return 3;
}

- (NSString *) tableView:(UITableView *)tableView
 titleForHeaderInSection:(NSInteger)section
{
    if (section)
        return @"Type de place désiré";
    return @"Informations acheteur";
}

- (NSString *) tableView:(UITableView *)tableView
 titleForFooterInSection:(NSInteger)section
{
    if (section)
        return @"⚠️ Place navette à 25 € pour externes et non 22 €";
    return nil;
}

- (UITableViewCell *) tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID1 = @"infoCell";
    static NSString *cellID2 = @"typeCell";
    UITableViewCell *cell;
    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:cellID1 forIndexPath:indexPath];
        PeopleCell *c = (PeopleCell *)cell;
        
        if (indexPath.row == 0)
        {
            c.label.text = @"Prénom Nom";
            c.field.placeholder = @"Guy Plantier";
            c.field.keyboardType = UIKeyboardTypeDefault;
            c.field.returnKeyType = UIReturnKeyNext;
            c.field.autocapitalizationType = UITextAutocapitalizationTypeWords;
        }
        else if (indexPath.row == 1)
        {
            c.label.text = @"Date de naissance";
            c.field.placeholder = @"21/01/2042";
            c.field.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            c.field.returnKeyType = UIReturnKeyNext;
            c.field.autocapitalizationType = UITextAutocapitalizationTypeWords;
        }
        else
        {
            c.label.text = @"École";
            c.field.placeholder = @"Signal Business School";
            c.field.keyboardType = UIKeyboardTypeDefault;
            c.field.returnKeyType = UIReturnKeyContinue;
            c.field.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        }
        c.field.delegate = self;
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:cellID2 forIndexPath:indexPath];
        
        NSDictionary *ticket = [[Data sharedData] JSON][@"tickets"][indexPath.row];
        cell.textLabel.text  = [NSString stringWithFormat:@"%@ · %.2f €", ticket[@"nom"], [ticket[@"prix"] doubleValue]];
        cell.selectionStyle  = ([ticket[@"dispo"] boolValue]) ? UITableViewCellSelectionStyleDefault
                                                              : UITableViewCellSelectionStyleNone;
        cell.accessoryType = ([selectionPlace isEqualToString:ticket[@"id"]]) ? UITableViewCellAccessoryCheckmark
                                                                              : UITableViewCellAccessoryNone;
        cell.textLabel.textColor = ([selectionPlace isEqualToString:ticket[@"id"]]) ? [UINavigationBar appearance].barTintColor
                                                                                    : [UIColor grayColor];
    }
    
    return cell;
}

- (void)      tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *ticket = [[Data sharedData] JSON][@"tickets"][indexPath.row];
    if (![ticket[@"dispo"] boolValue])
        return;
    selectionPlace = ticket[@"id"];
    [tableView reloadData];
}

#pragma mark - Text field delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(PeopleCell *)[[textField superview] superview]];
    
    if (indexPath.row < 2)
    {
        NSIndexPath *sibling = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        PeopleCell *cell = (PeopleCell*)[self.tableView cellForRowAtIndexPath:sibling];
        [cell.field becomeFirstResponder];
    }
    else
    {
        PeopleCell *cell = (PeopleCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.field resignFirstResponder];
    }
    
    return NO;
}

@end
