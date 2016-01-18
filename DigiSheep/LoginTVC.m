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
