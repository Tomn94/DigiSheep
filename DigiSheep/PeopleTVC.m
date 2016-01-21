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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendInfos:) name:@"sendInfosResa" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clear) name:@"clearFields" object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
}

#pragma mark - Actions

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
    
    if ([cell1.field.text isEqualToString:@""] || [cell2.field.text isEqualToString:@""])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Erreur"
                                                                       message:@"Remplissez les champs Nom et Date de naissance"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else if (![[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"(\\d{2})/(\\d{2})/(\\d{4})"] evaluateWithObject:cell2.field.text])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Erreur"
                                                                       message:@"Vérifiez le format de la date, avez les zéros\n(21/01/2042)"
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
    
    UIBarButtonItem *btnValider = self.navigationItem.rightBarButtonItem;
    UIActivityIndicatorView *spin = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spin startAnimating];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spin] animated:YES];
    
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
                                          [self.navigationItem setRightBarButtonItem:btnValider animated:YES];
                                          UIAlertController *alert = nil;
                                          
                                          if (error == nil && data != nil)
                                          {
                                              NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                              options:kNilOptions
                                                                                                error:nil];
                                              [[Data sharedData] setSubEvent:selectionPlace];
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
        NavettesTVC *navTVC = [[NavettesTVC alloc] initWithStyle:UITableViewStylePlain
                                                         andData:nav];
        [self.navigationController pushViewController:navTVC animated:YES];
    }
    else
    {
        ScanVendreVC *vc = [ScanVendreVC new];
        vc.navette = nil;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void) sendInfos:(NSNotification *)n
{
    if (n == nil || n.userInfo[@"qrcode"] == nil || selectionPlace == nil)
        return;
    
    PeopleCell *cell1 = (PeopleCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    PeopleCell *cell2 = (PeopleCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    PeopleCell *cell3 = (PeopleCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:@{ @"nom": cell1.field.text,
                                                                              @"date": cell2.field.text,
                                                                              @"ecole": cell3.field.text,
                                                                              @"qrcode": n.userInfo[@"qrcode"],
                                                                              @"idevent": selectionPlace }];
    if (n != nil && n.userInfo[@"navette"] != nil)
        [d setObject:n.userInfo[@"navette"] forKey:@"navette"];
    
    [[Data sharedData] sendResa:d];
}

- (void) clear
{
    PeopleCell *cell1 = (PeopleCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    PeopleCell *cell2 = (PeopleCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    PeopleCell *cell3 = (PeopleCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    cell1.field.text = @"";
    cell2.field.text = @"";
    cell3.field.text = @"";
    selectionPlace = nil;
    [self.tableView reloadData];
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
            c.field.tag = 21;
        }
        else if (indexPath.row == 1)
        {
            c.label.text = @"Date de naissance";
            c.field.placeholder = @"21/01/2042";
            c.field.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            c.field.returnKeyType = UIReturnKeyNext;
            c.field.autocapitalizationType = UITextAutocapitalizationTypeWords;
            c.field.tag = 42;
        }
        else
        {
            c.label.text = @"École";
            c.field.placeholder = @"Signal Business School";
            c.field.keyboardType = UIKeyboardTypeDefault;
            c.field.returnKeyType = UIReturnKeyContinue;
            c.field.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
            c.field.tag = 69;
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

- (BOOL)                textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string
{
    if (textField.tag != 42)
        return YES;
    
    // Date complète
    if (range.location == 10)
        return NO;
    
    // Seuls chiffres/slash autorisés
    if (range.length == 0 && ![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[string characterAtIndex:0]] && [string characterAtIndex:0] != '/')
        return NO;
    
    /*
    // Ajouter automatiquement un slash avant d'ajouter le 3e et 5e caractères
    if (range.length == 0 &&
        (range.location == 2 || range.location == 5)) {
        textField.text = [NSString stringWithFormat:@"%@/%@", textField.text, string];
        return NO;
    }
    
    // Suppression du tiret lors de la suppression du dernier chiffer
    if (range.length == 1 &&
        (range.location == 3 || range.location == 6))  {
        range.location--;
        range.length = 2;
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:@""];
        return NO;
    }*/
    
    return YES;
}

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
