//
//  NavettesTVC.m
//  DigiSheep
//
//  Created by Thomas Naudet on 19/01/2016.
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

#import "NavettesTVC.h"

@implementation NavettesTVC

- (instancetype) initWithStyle:(UITableViewStyle)style
                       andData:(NSDictionary *)data
{
    if (self = [super initWithStyle:style]) {
        [self setData:data];
        self.navigationItem.title = @"Sélection navette";
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Valider"
                                                                                    style:UIBarButtonItemStylePlain
                                                                                   target:self
                                                                                   action:@selector(valider)]];
        self.navigationItem.rightBarButtonItem.tintColor = [UINavigationBar appearance].tintColor;
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
}

- (void) setData:(NSDictionary *)data
{
    _data = data;
    
    NSMutableDictionary *t_navettes  = [NSMutableDictionary dictionary];
    NSMutableArray *t_navettesTitles = [NSMutableArray array];
    for (NSDictionary *navette in _data)
    {
        if ([[[Data sharedData] subEvent] isEqualToString:navette[@"idevent"]])
        {
            if ([t_navettesTitles containsObject:navette[@"departplace"]])
            {
                NSMutableArray *navettesPlace = t_navettes[navette[@"departplace"]];
                [navettesPlace addObject:navette];
            }
            else
            {
                [t_navettesTitles addObject:navette[@"departplace"]];
                NSMutableArray *navettesPlace = [NSMutableArray arrayWithObject:navette];
                [t_navettes setObject:navettesPlace forKey:navette[@"departplace"]];
            }
        }
    }
    navettes = [NSDictionary dictionaryWithDictionary:t_navettes];
    navettesTitles = [NSArray arrayWithArray:t_navettesTitles];
    
    [self.tableView reloadData];
}

- (void) valider
{
    if (selectionNavette == nil)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Vous n'avez pas choisi de navette"
                                                                       message:@"Tapez sur une de la liste pour la sélectionner."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    ScanVendreVC *vc = [ScanVendreVC new];
    vc.navette = selectionNavette;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [navettesTitles count];
}

- (NSInteger) tableView:(UITableView *)tableView
  numberOfRowsInSection:(NSInteger)section
{
    return [navettes[navettesTitles[section]] count];
}

- (NSString *) tableView:(UITableView *)tableView
 titleForHeaderInSection:(NSInteger)section
{
    return navettesTitles[section];
}

- (UITableViewCell *) tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellNavette"];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"cellNavette"];
    
    NSDictionary *navette = navettes[navettesTitles[indexPath.section]][indexPath.row];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *depart = [NSDateFormatter localizedStringFromDate:[dateFormatter dateFromString:navette[@"departure"]]
                                                      dateStyle:NSDateFormatterMediumStyle
                                                      timeStyle:NSDateFormatterShortStyle];
    NSString *arrivee = [NSDateFormatter localizedStringFromDate:[dateFormatter dateFromString:navette[@"arrival"]]
                                                       dateStyle:NSDateFormatterNoStyle
                                                       timeStyle:NSDateFormatterShortStyle];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Départ : %@", depart];
    if ([navette isEqualToDictionary:selectionNavette])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    if ([navette[@"restseats"] integerValue] > 1)
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld/%ld places disponibles · Arrivée %@",
                                     (long)[navette[@"restseats"] integerValue], (long)[navette[@"totseats"] integerValue], arrivee];
    else
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld/%ld place disponible · Arrivée %@",
                                     (long)[navette[@"restseats"] integerValue], (long)[navette[@"totseats"] integerValue], arrivee];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.imageView.image = [[UIImage imageNamed:@"bus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.imageView.tintColor = [UIColor grayColor];
    
    return cell;
}

- (void)      tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectionNavette = navettes[navettesTitles[indexPath.section]][indexPath.row];
    [tableView reloadData];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
