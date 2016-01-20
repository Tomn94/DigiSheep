//
//  NavettesTVC.m
//  DigiSheep
//
//  Created by Tomn on 19/01/2016.
//  Copyright © 2016 Tomn. All rights reserved.
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
    }
    return self;
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
