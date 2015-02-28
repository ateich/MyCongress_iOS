//
//  TableViewController.m
//  MyCongress
//
//  Created by HackReactor on 1/5/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "TableViewController.h"
#import "Politician.h"
#import "PoliticianDetailViewController.h"
#import "ColorScheme.h"

@interface TableViewController (){
    PoliticianDetailViewController *detailViewController;
    NSMutableDictionary *alphabetLetterPositions;
    NSArray *alphabetLetters;
    NSMutableArray *politicianDataRowsInSection;
    bool useFadeInAnimation;
    bool hideSectionIndex;
}

@end

@implementation TableViewController

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SunlightFactoryDidReceiveConnectionTimedOutForAllLawmakersNotification" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [ColorScheme backgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.politicians = [[NSMutableArray alloc] init];
    politicianDataRowsInSection = [[NSMutableArray alloc] init];
    
    [[UITableView appearance] setSectionIndexColor:[ColorScheme textColor]];
    [[UITableView appearance] setSectionIndexBackgroundColor:[UIColor clearColor]];
    
    self.title = @"Members of Congress";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionTimedOut:) name:@"SunlightFactoryDidReceiveConnectionTimedOutForAllLawmakersNotification" object:nil];
    
    alphabetLetters = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    alphabetLetterPositions = [[NSMutableDictionary alloc] init];
    
    for(int i=0; i<alphabetLetters.count; i++){
        [alphabetLetterPositions setObject:[NSNumber numberWithInt:i] forKey:[alphabetLetters objectAtIndex:i]];
        [politicianDataRowsInSection addObject:[[NSMutableArray alloc] init]];
    }
}

- (void)connectionTimedOut:(NSNotification*)notification{
    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"Cannot gather data"  message:@"Please check your internet connection and try again."  preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self.view.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 26;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)[[politicianDataRowsInSection objectAtIndex:section] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld",(long)indexPath.section,(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        UIView *card = [[UIView alloc] init];
        [card setTranslatesAutoresizingMaskIntoConstraints:NO];
        [card setBackgroundColor:[ColorScheme cardColor]];
        [cell addSubview:card];
        
        NSNumber *leftMargin = @15;
        NSNumber *halfMargin = @([leftMargin intValue]/2);
        NSNumber *quarterMargin = @([halfMargin intValue]/2);
        
        NSDictionary *views = NSDictionaryOfVariableBindings(card);
        NSDictionary *metrics = @{@"leftMargin":leftMargin, @"topMargin":halfMargin, @"largeTopMargin":halfMargin, @"sideMargin":@10, @"quarterMargin":quarterMargin};
        
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-largeTopMargin-[card]-0-|" options:0 metrics:metrics views:views]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[card]-leftMargin-|" options:0 metrics:metrics views:views]];
        
        Politician *thisPolitician = (Politician*)[[politicianDataRowsInSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//        int pictureWidth = 75;
        
        //Politician's Title and Name
        UILabel *name = [[UILabel alloc] init];
        [name setTranslatesAutoresizingMaskIntoConstraints:NO];
        name.text = [NSString stringWithFormat:@"%@. %@ %@", thisPolitician.title, thisPolitician.firstName, thisPolitician.lastName];
        
        
        //Politician's Party and State
        UILabel *state = [[UILabel alloc] init];
        [state setTranslatesAutoresizingMaskIntoConstraints:NO];
        [state setTextColor:[UIColor grayColor]];
        state.text = [NSString stringWithFormat:@"%@ - %@", thisPolitician.party, thisPolitician.state];
        
        [card addSubview:name];
        [card addSubview:state];
        views = NSDictionaryOfVariableBindings(name, state);
        
        [card addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[name]-quarterMargin-[state]-topMargin-|" options:0 metrics:metrics views:views]];
        [card addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[name]-|" options:0 metrics:metrics views:views]];
        [card addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[state]-|" options:0 metrics:metrics views:views]];
    }
    
    return cell;
}

-(NSMutableArray *)createPoliticiansFromDataArray:(NSArray *)politicianData{
    //Sort politicians my name
    NSSortDescriptor *sortLast = [NSSortDescriptor sortDescriptorWithKey:@"last_name" ascending:YES];
    NSSortDescriptor *sortFirst = [NSSortDescriptor sortDescriptorWithKey:@"first_name" ascending:YES];
    politicianData = [politicianData sortedArrayUsingDescriptors:@[sortLast, sortFirst]];
    
    NSMutableArray *politiciansFromData = [[NSMutableArray alloc] init];
    
    for(int i=0; i<politicianData.count; i++){
        NSDictionary *thisPoliticiansData = [politicianData objectAtIndex:i];
        Politician *aPolitician = [[Politician alloc] init];
        
        [aPolitician setFirstName: [thisPoliticiansData objectForKey:@"first_name"]];
        [aPolitician setLastName: [thisPoliticiansData objectForKey:@"last_name"]];
        [aPolitician setGender: [thisPoliticiansData objectForKey:@"gender"]]; //May have an issue, check this
        
        [aPolitician setEmail: [thisPoliticiansData objectForKey:@"oc_email"]];
        [aPolitician setPhone: [thisPoliticiansData objectForKey:@"phone"]];
        [aPolitician setEmail: [thisPoliticiansData objectForKey:@"oc_email"]];
        [aPolitician setTwitter: [thisPoliticiansData objectForKey:@"twitter_id"]];
        [aPolitician setYoutubeID: [thisPoliticiansData objectForKey:@"youtube_id"]];
        [aPolitician setWebsite: [thisPoliticiansData objectForKey:@"website"]];
        
        NSString *firstLetterOfPoliticiansLastName = [aPolitician.lastName substringToIndex:1];
        
        NSString *party = [thisPoliticiansData objectForKey:@"party"];
        if([party isEqual: @"D"]){
            [aPolitician setParty: @"Democrat"];
        } else {
            [aPolitician setParty: @"Republican"];
        }
        
        [aPolitician setTitle: [thisPoliticiansData objectForKey:@"title"]];
        [aPolitician setState: [thisPoliticiansData objectForKey:@"state_name"]];
        [aPolitician setBioguideID:[thisPoliticiansData objectForKey:@"bioguide_id"]];
        
        if([aPolitician.title isEqualToString:@"Sen"] || [aPolitician.title isEqualToString:@"Rep"]){
            [politiciansFromData addObject:aPolitician];
            int sectionNumber = (int)[self tableView:self.tableView sectionForSectionIndexTitle:firstLetterOfPoliticiansLastName atIndex:0];
            NSMutableArray *sectionRow = [politicianDataRowsInSection objectAtIndex:sectionNumber];
            [sectionRow addObject:aPolitician];
        }
    }
    return politiciansFromData;
}

/* Show more details about the selected politician */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    detailViewController = [[PoliticianDetailViewController alloc] init];
    [detailViewController setPolitician:[[politicianDataRowsInSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    [[self navigationController] pushViewController:detailViewController animated:YES];
}

-(void)useFadeInAnimation:(bool)fadeIn{
    self.tableView.alpha = 0;
    useFadeInAnimation = fadeIn;
}

-(void)updateTableViewWithNewData:(NSMutableArray *)data{
    self.politicians = data;
    [self.tableView reloadData];
    
    if(useFadeInAnimation){
        [UIView animateWithDuration:[ColorScheme fadeInTime] animations:^{
            [self.tableView setAlpha:1.0f];
        } completion:^(BOOL finished) {}];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if(hideSectionIndex){
        return nil;
    } else {
        return alphabetLetters;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index {
    return [[alphabetLetterPositions objectForKey:title] integerValue];
}

-(void)hideSectionIndexBar:(BOOL)hide{
    hideSectionIndex = hide;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
