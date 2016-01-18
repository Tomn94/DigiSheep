//
//  LoginTVC.m
//  DigiSheep
//
//  Created by Tomn on 18/01/2016.
//  Copyright © 2016 Tomn. All rights reserved.
//

#import "LoginTVC.h"

@implementation LoginTVC

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) connexion
{
    [_idField  resignFirstResponder];
    [_passField resignFirstResponder];
    if ([_idField.text isEqualToString:@""] || [_passField.text isEqualToString:@""])
        return;
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession              *defaultSession      = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                                   delegate:nil
                                                                              delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURL *url = [NSURL URLWithString:URL_LOGIN];
    
    NSString *username = [Data encoderPourURL:_idField.text];
    NSString *password = [Data encoderPourURL:_passField.text];
    NSString *body     = [NSString stringWithFormat:@"login=%@&password=%@", username, password];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:request
                                                       completionHandler:^(NSData *data, NSURLResponse *r, NSError *error)
                                      {
                                          [[Data sharedData] updLoadingActivity:NO];
                                          UIAlertController *alert = nil;
                                          
                                          if (error == nil && data != nil)
                                          {
                                              NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:kNilOptions
                                                                                                     error:nil];
                                              if ([JSON[@"status"] intValue] == 1)
                                              {
                                                  [[Data sharedData] setLogin:username];
                                                  [[Data sharedData] setPass:password];
                                                  [[Data sharedData] setSellEvent:JSON[@"data"][@"sellevent"]];
                                                  
                                                  // TODO: Charger UI
                                              }
                                              else
                                                  alert = [UIAlertController alertControllerWithTitle:@"Erreur"
                                                                                              message:[NSString stringWithFormat:@"Cause :\n%@ (erreur %d)", JSON[@"cause"], [JSON[@"status"] intValue]]
                                                                                       preferredStyle:UIAlertControllerStyleAlert];
                                          }
                                          else
                                              alert = [UIAlertController alertControllerWithTitle:@"Erreur"
                                                                                          message:@"Impossible de se connecter"
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                                          if (alert != nil)
                                          {
                                              [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                                              [self presentViewController:alert animated:YES completion:nil];
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
