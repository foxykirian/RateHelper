//
//  ViewController.m
//  RateHelperExample
//
//  Created by Kirill Dyakonov on 01.03.15.
//  Copyright (c) 2015 Kirill Dyakonov. All rights reserved.
//

#import "FirstVC.h"
#import "RateHelperSettings.h"

@interface FirstVC ()

@end

@implementation FirstVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"1-st Screen";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateLabel];
}

- (IBAction)resetCounter:(id)sender
{
    // clearing settings manually
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRateHelperSettings];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[RateHelperSettings sharedSettings] initSettings];
    [self updateLabel];
}

- (void)updateLabel
{
    NSString *text;
    if ([RateHelperSettings sharedSettings].isActual) {
        if ([RateHelperSettings sharedSettings].askAfterN == 0) {
            text = @"RateHelper will be on 2-nd Screen";
        } else {
            text = [NSString stringWithFormat:@"RateHelper will be shown after\n\n%lu\n\nappears of 2-nd Screen", (unsigned long)[RateHelperSettings sharedSettings].askAfterN];
        }
    } else {
        text = @"RateHelper will not be shown in this version. Change version manually in Info.plist or Reset settings";
    }
    _labelInfo.text = text;
}

@end
