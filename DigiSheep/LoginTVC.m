//
//  LoginTVC.m
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

#import "LoginTVC.h"


@implementation LoginVC

- (void) viewDidLoad
{
	[super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showText:) name:@"showTextConnect" object:nil];
}

- (void) showText:(NSNotification *)notif
{
    if (notif.userInfo)
    {
        [_updSpin startAnimating];
        _updTxt.text = notif.userInfo[@"message"];
    }
    else
    {
        [_updSpin stopAnimating];
        _updTxt.text = @"";
    }
}

@end



@implementation LoginTVC

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    _idField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"login"];
}

- (void) connexion
{
    [_idField  resignFirstResponder];
    [_passField resignFirstResponder];
    if ([_idField.text isEqualToString:@""] || [_passField.text isEqualToString:@""])
        return;
    if (chargement)
        return;
    
    chargement = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showTextConnect" object:nil
                                                      userInfo:@{ @"message": @"Authentification…" }];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession              *defaultSession      = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                                   delegate:nil
                                                                              delegateQueue:[NSOperationQueue mainQueue]];
    
    // CONNEXION À LA BDD
    NSURL *url = [NSURL URLWithString:URL_LOGIN];
    
    NSString *username = [Data encoderPourURL:_idField.text];
    NSString *password = [Data encoderPourURL:[Data hashed_string:[_passField.text stringByAppendingString:@"p8brURUs"]]];
    NSString *body     = [NSString stringWithFormat:@"login=%@&password=%@", username, password];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:request
                                                       completionHandler:^(NSData *data, NSURLResponse *r, NSError *error)
                                      {
                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"showTextConnect" object:nil
                                                                                            userInfo:@{ @"message": @"Mise à jour des données…" }];
                                          [[Data sharedData] updLoadingActivity:NO];
                                          UIAlertController *alert = nil;
                                          
                                          if (error == nil && data != nil)
                                          {
                                              NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:kNilOptions
                                                                                                     error:nil];
                                              if ([JSON[@"status"] intValue] == 1)
                                              {
                                                  // CONNEXION AU JSON EVENTS
                                                  NSURL *url2 = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%d", URL_JSON, (int)arc4random_uniform(9999)]];
                                                  NSMutableURLRequest *request2 = [[NSMutableURLRequest alloc] initWithURL:url2];
                                                  NSURLSessionDataTask *dataTask2 = [defaultSession dataTaskWithRequest:request2
                                                                                                     completionHandler:^(NSData *data2, NSURLResponse *r, NSError *error2)
                                                    {
                                                        [[Data sharedData] updLoadingActivity:NO];
                                                        chargement = NO;
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"showTextConnect" object:nil
                                                                                                          userInfo:@{ @"message": @"Connecté" }];
                                                        UIAlertController *alert2 = nil;
                                                        
                                                        if (error2 == nil && data2 != nil)
                                                        {
                                                            NSArray *JSON2 = [NSJSONSerialization JSONObjectWithData:data2
                                                                                                             options:kNilOptions
                                                                                                               error:nil];
                                                            if (JSON2 != nil && [JSON2 count])
                                                            {
                                                                // CONNECTÉ
                                                                NSDictionary *e = nil;
                                                                for (NSDictionary *event in JSON2)
                                                                {
                                                                    if ([event[@"id"] integerValue] == [JSON[@"data"][@"sellevent"] integerValue])
                                                                    {
                                                                        e = event;
                                                                        break;
                                                                    }
                                                                }
                                                                
                                                                // INFOS EVENT TROUVÉES
                                                                if (e != nil)
                                                                {
                                                                    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                                                                    [def setValue:_idField.text forKey:@"login"];
                                                                    [def synchronize];
                                                                    
                                                                    [[Data sharedData] setLogin:username];
                                                                    [[Data sharedData] setPass:password];
                                                                    [[Data sharedData] setSellEvent:[JSON[@"data"][@"sellevent"] integerValue]];
                                                                    [[Data sharedData] setJSON:e];
                                                                    
                                                                    // CRÉATION UI
                                                                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                    UINavigationController *vc = [sb instantiateViewControllerWithIdentifier:@"TBC"];
                                                                    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                                                                    [self presentViewController:vc animated:YES completion:^{
                                                                        _idField.text   = @"";
                                                                        _passField.text = @"";
                                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"showTextConnect" object:nil];
                                                                    }];
                                                                }
                                                                else  // ERREURS JSON
                                                                    alert2 = [UIAlertController alertControllerWithTitle:@"Erreur"
                                                                                                                 message:@"Impossible de récupérer l'événement."
                                                                                                          preferredStyle:UIAlertControllerStyleAlert];
                                                            }
                                                            else  // ERREURS JSON
                                                                alert2 = [UIAlertController alertControllerWithTitle:@"Erreur"
                                                                                                             message:@"Impossible de lire les événements."
                                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                                                        }
                                                        else
                                                            alert2 = [UIAlertController alertControllerWithTitle:@"Erreur"
                                                                                                         message:@"Impossible de se connecter aux événements"
                                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                                                        if (alert2 != nil)
                                                        {
                                                            [alert2 addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                                                            [self presentViewController:alert2 animated:YES completion:nil];
                                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"showTextConnect" object:nil];
                                                        }
                                                    }];
                                                  [dataTask2 resume];
                                                  [[Data sharedData] updLoadingActivity:YES];
                                              }
                                              else  // ERREURS BDD
                                                  alert = [UIAlertController alertControllerWithTitle:@"Erreur"
                                                                                              message:[NSString stringWithFormat:@"Cause :\n%@ (erreur %d)", JSON[@"cause"], [JSON[@"status"] intValue]]
                                                                                       preferredStyle:UIAlertControllerStyleAlert];
                                          }
                                          else
                                              alert = [UIAlertController alertControllerWithTitle:@"Erreur"
                                                                                          message:@"Impossible de se connecter à la base de données"
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                                          if (alert != nil)
                                          {
                                              chargement = NO;
                                              [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                                              [self presentViewController:alert animated:YES completion:nil];
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"showTextConnect" object:nil];
                                          }
                                      }];
    [dataTask resume];
    [[Data sharedData] updLoadingActivity:YES];
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
        return 1;
    return 2;
}

- (void)      tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self connexion];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Text field delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if ([_idField isFirstResponder])
        [_passField becomeFirstResponder];
    else
        [self connexion];
    
    return NO;
}

@end
