//
//  ActionViewController.m
//  Influence Explorer
//
//  Created by HackReactor on 1/22/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Tokens.h"
#import "ReadabilityFactory.h"
#import "SunlightFactory.h"

@interface ActionViewController (){
    ReadabilityFactory *readabilityFactory;
    SunlightFactory *sunlightAPI;
}

//@property(strong,nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    readabilityFactory = [[ReadabilityFactory alloc] init];
    sunlightAPI = [[SunlightFactory alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveReadableArticle:) name:@"ReadabilityFactoryDidReceiveReadableArticleNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveEntityData:) name:@"SunlightFactoryDidReceiveSearchForEntityNotification" object:nil];
    
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
                    if(url) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSLog(@"%@", [url description]);
                            [self parseUrlForArticle:url];
                        }];
                    } else if(error){
                        NSLog(@"%@", [error description]);
                    }
                }];
                break;
            }
        }
    }
}

-(void)parseUrlForArticle:(NSURL*)url{
    NSString *apiUrl = [NSString stringWithFormat:@"https://readability.com/api/content/v1/parser?url=%@?currentPage=all&token=%@", [url absoluteString], [Tokens getReadabilityToken]];
    NSLog(@"%@", apiUrl);
    [readabilityFactory makeReadableArticleFromUrl:apiUrl];
}

-(void)didReceiveReadableArticle:(NSNotification*)notification{
    NSLog(@"Notification received");
    NSDictionary *userInfo = [notification userInfo];
    NSString *articleHTML = [[userInfo objectForKey:@"content"] objectForKey:@"content"];
    
    //contains a dictionary of keys: word types and values: dictionary of words
    NSMutableDictionary *properNouns = [self parseReadableArticleForProperNouns:articleHTML];
    [self checkIfProperNounsArePoliticians:[properNouns objectForKey:@"PersonalName"]];
}

-(void)checkIfProperNounsArePoliticians:(NSMutableDictionary*)properNouns{
    if(properNouns){
        for (NSString *person in properNouns) {
            NSLog(@"%@", person);
            //check if this person is a recognized politician
            //doing this check locally would greatly increase performance
            //vs making an api call for each person to verify they are a politican
            //  then making additional transparency calls for each verified person
            [sunlightAPI searchForEntity:person];
        }
    }
}

-(void)didReceiveEntityData:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSArray *politicians = [userInfo objectForKey:@"results"];
    NSLog(@"%@", politicians);
    
    if(politicians.count > 0){
//        NSString *transparencyID = [[politicians objectAtIndex:0] objectForKey:@"id"];
//        NSLog(@"transparency id: %@", transparencyID);
        NSLog(@"%@", [politicians description]);
        
//        [sunlightAPI getTopDonorsForLawmaker:transparencyID];
//        [sunlightAPI getTopDonorIndustriesForLawmaker:transparencyID];
//        [sunlightAPI getTopDonorSectorsForLawmaker:transparencyID];
    } else {
        NSLog(@"[PoliticianDetailViewController.m] WARNING: Politician not found while checking for transparency id - Donation data will not be shown");
    }
}

-(NSMutableDictionary*)parseReadableArticleForProperNouns:(NSString*)content{
    NSMutableDictionary *properNouns = [[NSMutableDictionary alloc] init];
    
    //strip out all HTML tags and political titles
    content = [self stringByStrippingHTML:content];
    content = [self removePoliticalTitles:content];
    
    //Get all names of people and organizations with NSLinguisticTagger
    NSLinguisticTaggerOptions tagOptions = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:[NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:tagOptions];
    tagger.string = content;
    
    [tagger enumerateTagsInRange:NSMakeRange(0, [content length]) scheme:NSLinguisticTagSchemeNameType options:tagOptions usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
        NSString *token = [content substringWithRange:tokenRange];
        if(![tag isEqualToString:@"OtherWord"]){
            if(![properNouns objectForKey:tag]){
                [properNouns setObject:[[NSMutableDictionary alloc] init] forKey:tag];
            }
            [[properNouns objectForKey:tag] setObject:@YES forKey:token];
        }
    }];
    return properNouns;
}

-(NSString*)removePoliticalTitles:(NSString*)content{
    NSMutableArray *wordsToRemove = [[NSMutableArray alloc] init];
    [wordsToRemove addObject:@"Sen."];
    [wordsToRemove addObject:@"Sen"];
    [wordsToRemove addObject:@"Rep."];
    [wordsToRemove addObject:@"Rep"];
    [wordsToRemove addObject:@"Speaker"];
    [wordsToRemove addObject:@"Leader"];
    [wordsToRemove addObject:@"Whip"];
    [wordsToRemove addObject:@"Chairman"];
    
    for(int i=0; i<wordsToRemove.count; i++){
        content = [content stringByReplacingOccurrencesOfString:[wordsToRemove objectAtIndex:i] withString:@". "];
    }
    content = [content stringByReplacingOccurrencesOfString:@"." withString:@" "];
    
    return content;
}

-(NSString*)stringByStrippingHTML:(NSString*)s {
    NSRange r;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end
