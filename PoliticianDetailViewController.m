//
//  PoliticianDetailViewController.m
//  MyCongress
//
//  Created by HackReactor on 1/6/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "PoliticianDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

//Need to change this to a scrollview
@interface PoliticianDetailViewController (){
    Politician *politician;
    
    /* LAYOUT CONSTRAINTS */
    int sectionVerticalMargin;
    int subSectionVerticalMargin;
    int topBarHeight;
    
    UIScrollView *scrollView;
    UIView *contentView;
    
    NSString *topDonorLoaded;
    NSString *topDonorIndustriesLoaded;
    NSString *transparencyIdLoaded;
    NSString *topDonorSectorsLoaded;
    
    UIView *contactSection;
    UIView *individualDonorsSection;
    UIView *industryDonorsSection;
    UIView *sectorDonorsSection;
    
    NSLayoutConstraint *donorsByIndustryHeaderTop;
    NSLayoutConstraint *donorsBySectorHeaderTop;
    
    SunlightFactory *sunlightAPI;
}

@end

@implementation PoliticianDetailViewController

@synthesize contactActions;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = [NSString stringWithFormat:@"%@. %@ %@", politician.title, politician.firstName, politician.lastName];
    
    scrollView = [[UIScrollView alloc] init];
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:scrollView];
//    [scrollView setBackgroundColor:[UIColor greenColor]];
    
    contentView = [[UIView alloc] init];
//    [contentView setBackgroundColor:[UIColor redColor]];
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [scrollView addSubview:contentView];
    
    //Politician's Photo
    UIImageView *photo = [[UIImageView alloc] init];
    [photo setBackgroundColor:[UIColor blackColor]];
    [photo setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIImage *politicianPhoto = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", politician.bioguideID]];
    [photo setImage:politicianPhoto];
    [photo setContentMode:UIViewContentModeScaleAspectFit];
    
    double photoSize = 112.5;
    
    UIColor *bgAndBorderColor = [UIColor blackColor];
//    UIColor *bgAndBorderColor = [UIColor colorWithRed:112.0/255 green:138.0/255 blue:153.0/255 alpha:1];
    photo.layer.backgroundColor=[bgAndBorderColor CGColor];
    photo.layer.cornerRadius=photoSize/2;
    photo.layer.borderWidth=2.0;
    photo.layer.masksToBounds = YES;
    photo.layer.borderColor=[bgAndBorderColor CGColor];
    
    [contentView addSubview:photo];
    
    if(!politicianPhoto){
        NSLog(@"MISSING PHOTO %@.jpg", politician.bioguideID);
        
        //Set to default image
        [photo setImage:[UIImage imageNamed:@"MissingImageInverted.jpg"]];
        
        //Hide the image if there isn't one to show
//        photoSize = 0;
    }
    
    //Contact Section
    contactSection =[[UIView alloc] init];
    [contactSection setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView addSubview:contactSection];
    
    //Individual Donors Section
    individualDonorsSection =[[UIView alloc] init];
    [individualDonorsSection setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView addSubview:individualDonorsSection];
//    [individualDonorsSection setBackgroundColor:[UIColor orangeColor]];
    
    //Industry Donors Section
    industryDonorsSection =[[UIView alloc] init];
    [industryDonorsSection setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView addSubview:industryDonorsSection];
    
    //Sector Donors Section
    sectorDonorsSection =[[UIView alloc] init];
    [sectorDonorsSection setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView addSubview:sectorDonorsSection];
    
    //AUTO LAYOUT (VFL)
    NSDictionary *views = NSDictionaryOfVariableBindings(scrollView, contentView);
    
    //Scroll View Layout
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollView]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[scrollView]-0-|" options:0 metrics:nil views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|" options:0 metrics:nil views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|" options:0 metrics:nil views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView(==scrollView)]|" options:0 metrics:nil views:views]];
    
    //Entire page layout, vertically
    NSDictionary *metrics = @{@"sectionPadding": @20, @"photoSize": [NSNumber numberWithDouble:photoSize]};
    views = NSDictionaryOfVariableBindings(contentView, photo, contactSection, individualDonorsSection, industryDonorsSection, sectorDonorsSection);
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sectionPadding-[photo(photoSize)]-sectionPadding-[contactSection]-sectionPadding-[individualDonorsSection]-sectionPadding-[industryDonorsSection]-sectionPadding-[sectorDonorsSection]|" options:0 metrics:metrics views:views]];
    
    //Photo layout
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:photo attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:photoSize]];
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:photo attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contactSection]-0-|" options:0 metrics:nil views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[individualDonorsSection]-0-|" options:0 metrics:nil views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[industryDonorsSection]-0-|" options:0 metrics:nil views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[sectorDonorsSection]-0-|" options:0 metrics:nil views:views]];
    
    [self createContactSection];

    
    
    //Enable sharing actions
    contactActions = [[ContactActionsFactory alloc] init];
    [contactActions setViewController:self];
    
    //Listen for asynchronous callbacks of politician donor data
    topDonorLoaded = @"SunlightFactoryDidReceiveGetTopDonorsForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticianData:) name:topDonorLoaded object:nil];
    
    topDonorIndustriesLoaded = @"SunlightFactoryDidReceiveGetTopDonorIndustriesForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticianIndustryData:) name:topDonorIndustriesLoaded object:nil];
    
    transparencyIdLoaded = @"SunlightFactoryDidReceiveGetTransparencyIDNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTransparencyId:) name:transparencyIdLoaded object:nil];
    
    topDonorSectorsLoaded = @"SunlightFactoryDidReceiveGetTopDonorSectorsForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticianDataSectorData:) name:topDonorSectorsLoaded object:nil];
    
    
    //get transparency id to use in receiving politician donor data
    sunlightAPI = [[SunlightFactory alloc] init];
    [sunlightAPI getLawmakerTransparencyIDFromFirstName:politician.firstName andLastName:politician.lastName];
}

-(void)createContactSection{
//    [contactSection setBackgroundColor:[UIColor yellowColor]];
    [contactSection setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSNumber *leftMargin = [[NSNumber alloc] initWithInt:25];
    NSDictionary *metrics = @{@"leftMargin":leftMargin, @"buttonSize":@30, @"buttonSpacer":@15, @"topMargin":@10};
    
    //create section header
    UILabel *header = [[UILabel alloc] init];
    [header setTranslatesAutoresizingMaskIntoConstraints:NO];
    header.text = @"Contact";
    [contactSection addSubview:header];

    [contactSection addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[header]-0-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(header)]];
    
    NSMutableArray *contactMethods = [[NSMutableArray alloc] init];
    if(politician.twitter){
        //        [contactMethods addObject:[NSArray arrayWithObjects:@"twitter", @"TEST", nil]];
    }
    if(politician.youtubeID){
        //        [contactMethods addObject:[NSArray arrayWithObjects:@"youtube", @"TEST", nil]];
    }
    if(politician.phone){
        [contactMethods addObject:[NSArray arrayWithObjects:@"phone", @"makePhoneCall", nil]];
    }
    if(politician.email){
        [contactMethods addObject:[NSArray arrayWithObjects:@"email", @"sendEmail", nil]];
    }
    if(politician.website){
        //        [contactMethods addObject:[NSArray arrayWithObjects:@"website", @"loadWebsite", nil]];
    }
    
    
    id leftSide;

    
    UIView *buttonsView = [[UIView alloc] init];
    [contactSection addSubview:buttonsView];
    [buttonsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contactSection addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[header]-0-[buttonsView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(buttonsView, header)]];
    [contactSection addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[buttonsView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(buttonsView, header)]];
    
    
    //Create a contact button for each available contact method
    for(int i=0; i<contactMethods.count; i++){
        UIButton *contactButton = [[UIButton alloc] init];
        [contactSection addSubview:contactButton];
        
        //set button selector with variable?
        SEL aSelector = NSSelectorFromString([[contactMethods objectAtIndex:i] objectAtIndex:1]);
        [contactButton addTarget:self action:aSelector forControlEvents:UIControlEventTouchDown];
        
        [contactButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [contactButton setBackgroundImage:[UIImage imageNamed:[[contactMethods objectAtIndex:i] objectAtIndex:0]] forState:UIControlStateNormal];
        
        [buttonsView addSubview:contactButton];
        
        if(!leftSide){
            [buttonsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[contactButton(==buttonSize)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(contactButton)]];
        } else {
            [buttonsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[leftSide]-buttonSpacer-[contactButton(==buttonSize)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(contactButton, leftSide)]];
        }
        [buttonsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[contactButton(==buttonSize)]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(contactButton)]];
        
        
        //Save this button to be used in left positioning the next button
        leftSide = contactButton;
    }
}

-(void)createDonorDataSectionWithDonors:(NSArray*)donors andSection:(UIView*)section andTitle:(NSString*)title {
    UILabel *top = [[UILabel alloc] init];
    [top setTranslatesAutoresizingMaskIntoConstraints:NO];
    [top setFont:[UIFont boldSystemFontOfSize:16]];
    [section addSubview:top];
    top.text = title;
    
    NSNumber *leftMargin = [NSNumber numberWithInt:25];
    NSDictionary *metrics = @{@"leftMargin":leftMargin, @"topMargin":@10, @"largeTopMargin":@15};
    
    [section addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[top]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(top)]];
    [section addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[top]-0-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(top)]];
    
    for(int i=0; i<donors.count; i++){
        NSDictionary *donor = [donors objectAtIndex:i];
        NSString *totalAmount;
        
        if(section == individualDonorsSection){
            totalAmount = [donor objectForKey:@"total_amount"];
        } else if (section == industryDonorsSection || section == sectorDonorsSection){
            totalAmount = [donor objectForKey:@"amount"];
        }
        NSString *donorName = [donor objectForKey:@"name"];
        if(section == sectorDonorsSection){
            donorName = [sunlightAPI convertSectorCode:[donor objectForKey:@"sector"]];
        }
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *total = [numberFormatter numberFromString:totalAmount];
        
        [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
        totalAmount = [numberFormatter stringFromNumber:total];
        
        NSString *labelText = donorName;//[NSString stringWithFormat:@"%@ - %@", donorName, totalAmount];
        
        //If donor is written in ALL CAPS, make it proper nouns (All Caps)
        if ([[labelText uppercaseStringWithLocale:[NSLocale currentLocale]] isEqualToString:labelText])
        {
            labelText = [[labelText lowercaseString] capitalizedString];
        }
        
        UILabel *label = [[UILabel alloc] init];
        [label setNumberOfLines:0];
        [section addSubview:label];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        label.text = labelText;
        label.adjustsFontSizeToFitWidth = YES;
        
        UILabel *moneyLabel = [[UILabel alloc] init];
        [label setNumberOfLines:0];
        [section addSubview:moneyLabel];
        [moneyLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        moneyLabel.text = totalAmount;
        moneyLabel.adjustsFontSizeToFitWidth = YES;
        [moneyLabel setTextColor:[UIColor grayColor]];
        
        
        NSDictionary *views;
        
        if(donors.count-1 == i){
            views = NSDictionaryOfVariableBindings(top, label, moneyLabel);
            [section addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-topMargin-[label]-[moneyLabel]-|" options:0 metrics:metrics views:views]];
        } else {
            views = NSDictionaryOfVariableBindings(top, label, moneyLabel);
            [section addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-largeTopMargin-[label]-[moneyLabel]" options:0 metrics:metrics views:views]];
        }
        [section addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[label]-0-|" options:0 metrics:metrics views:views]];
        [section addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[moneyLabel]-0-|" options:0 metrics:metrics views:views]];
        
        top = moneyLabel;
    }
//    [section setBackgroundColor:[UIColor purpleColor]];
    
    
    
    [UIView animateWithDuration:1.0f animations:^{
        [section setAlpha:1.0f];
    } completion:^(BOOL finished) {}];
}

- (void)didReceivePoliticianData:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSLog(@"%@", [userInfo description]);
    NSArray *donors = [userInfo objectForKey:@"results"];
    
    topDonorLoaded = @"SunlightFactoryDidReceiveGetTopDonorsForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:topDonorLoaded object:nil];
    
    [individualDonorsSection setAlpha:0.0f];
    [self createDonorDataSectionWithDonors:donors andSection:individualDonorsSection andTitle:@"Top Individual Donors"];
}

-(void)didReceivePoliticianIndustryData:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSArray *donorIndustries = [userInfo objectForKey:@"results"];
    
    topDonorIndustriesLoaded = @"SunlightFactoryDidReceiveGetTopDonorIndustriesForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:topDonorIndustriesLoaded object:nil];
    
    [industryDonorsSection setAlpha:0.0f];
    [self createDonorDataSectionWithDonors:donorIndustries andSection:industryDonorsSection andTitle:@"Top Donors by Industry"];
}

-(void)didReceivePoliticianDataSectorData:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSArray *donorSectors = [userInfo objectForKey:@"results"];
    
    topDonorSectorsLoaded = @"SunlightFactoryDidReceiveGetTopDonorSectorsForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:topDonorSectorsLoaded object:nil];
    
    [sectorDonorsSection setAlpha:0.0f];
    [self createDonorDataSectionWithDonors:donorSectors andSection:sectorDonorsSection andTitle:@"Top Donors by Sector"];
}

-(void)didReceiveTransparencyId:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSArray *politicians = [userInfo objectForKey:@"results"];
    
    transparencyIdLoaded = @"SunlightFactoryDidReceiveGetTransparencyIDNotification";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:transparencyIdLoaded object:nil];
    
    if(politicians.count > 0){
        NSString *transparencyID = [[politicians objectAtIndex:0] objectForKey:@"id"];
        NSLog(@"transparency id: %@", transparencyID);
        
        [sunlightAPI getTopDonorsForLawmaker:transparencyID];
        [sunlightAPI getTopDonorIndustriesForLawmaker:transparencyID];
        [sunlightAPI getTopDonorSectorsForLawmaker:transparencyID];
    } else {
        NSLog(@"[PoliticianDetailViewController.m] WARNING: Politician not found while checking for transparency id - Donation data will not be shown");
    }
}

#pragma mark - Contact Delegate Methods
-(void)TEST{
    NSLog(@"TEST");
}

-(void)sendEmail {
    [contactActions composeEmail];
}

-(void)makePhoneCall {
    [contactActions makePhoneCall:politician.phone];
}

-(void)loadWebsite {
    [contactActions loadWebsite:politician.website];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)setPolitician:(Politician *)newPolitician{
    politician = newPolitician;
}

-(void)dealloc{
    topDonorLoaded = @"SunlightFactoryDidReceiveGetTopDonorsForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:topDonorLoaded object:nil];
    
    topDonorIndustriesLoaded = @"SunlightFactoryDidReceiveGetTopDonorIndustriesForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:topDonorIndustriesLoaded object:nil];
    
    transparencyIdLoaded = @"SunlightFactoryDidReceiveGetTransparencyIDNotification";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:transparencyIdLoaded object:nil];
    
    topDonorSectorsLoaded = @"SunlightFactoryDidReceiveGetTopDonorSectorsForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:topDonorSectorsLoaded object:nil];
}

@end
