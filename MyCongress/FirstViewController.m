//
//  FirstViewController.m
//  MyCongress
//
//  Created by Andrew Teich on 12/11/14.
//  Copyright (c) 2014 Andrew Teich. All rights reserved.
//

#import "FirstViewController.h"
#import "SunlightFactory.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Text input field for zip code
    //Search by Zip Code (button)
    //          or
    //Use My Current Location (button)
    
    UIView *containerView = [[UIView alloc] init];
    [containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:containerView];
    
    UIView *topSpacer = [[UIView alloc] init];
    [topSpacer setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:topSpacer];
    
    UIView *bottomSpacer = [[UIView alloc] init];
    [bottomSpacer setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:bottomSpacer];
    
    UITextField *zipCodeField = [[UITextField alloc] init];
    [zipCodeField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [zipCodeField setPlaceholder:@"Enter your Zip Code Here"];
    [zipCodeField setTextAlignment:NSTextAlignmentCenter];
    [containerView addSubview:zipCodeField];
    [zipCodeField becomeFirstResponder];
    
    UIButton *searchByZipCode = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [searchByZipCode setTranslatesAutoresizingMaskIntoConstraints:NO];
    [searchByZipCode setTitle:@"Search by Zip Code" forState:UIControlStateNormal];
    [containerView addSubview:searchByZipCode];
    
    UILabel *or = [[UILabel alloc] init];
    [or setTranslatesAutoresizingMaskIntoConstraints:NO];
    [or setText:@"or"];
    [or setTextAlignment:NSTextAlignmentCenter];
    [containerView addSubview:or];
    
    UIButton *searchByCurrentLocation = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [searchByCurrentLocation setTranslatesAutoresizingMaskIntoConstraints:NO];
    [searchByCurrentLocation setTitle:@"Use My Current Location" forState:UIControlStateNormal];
    [containerView addSubview:searchByCurrentLocation];
    
    //AUTOLAYOUT
    NSDictionary *metrics = @{@"tabBarHeight":[NSNumber numberWithDouble:self.tabBarController.tabBar.frame.size.height]};
    NSDictionary *views = NSDictionaryOfVariableBindings(containerView, topSpacer, bottomSpacer, zipCodeField, searchByZipCode, or, searchByCurrentLocation);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[topSpacer]-[containerView]-[bottomSpacer(==topSpacer)]-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[containerView]-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[topSpacer]-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[bottomSpacer]-|" options:0 metrics:nil views:views]];
    
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[zipCodeField]-[searchByZipCode]-[or]-[searchByCurrentLocation]-tabBarHeight-|" options:0 metrics:metrics views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[zipCodeField]-|" options:0 metrics:nil views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[searchByZipCode]-|" options:0 metrics:nil views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[or]-|" options:0 metrics:nil views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[searchByCurrentLocation]-|" options:0 metrics:nil views:views]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
