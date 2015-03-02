//
//  SecondVC.m
//  RateHelperExample
//
//  Created by Kirill Dyakonov on 01.03.15.
//  Copyright (c) 2015 Kirill Dyakonov. All rights reserved.
//

#import "SecondVC.h"
#import "RateHelperView.h"

#define VIEW_RATE_H 140

@interface SecondVC () <RateHelperViewDelegate>
{
    CGFloat yTop;
    RateHelperView *viewRate;
    CGRect frameRateViewShown, frameRateViewHidden;
}
@end

@implementation SecondVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"2-nd Screen";
    yTop = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    if ([RateHelperSettings sharedSettings].isActual) {
        if ([RateHelperSettings sharedSettings].askAfterN == 0) {
            frameRateViewHidden = CGRectMake(0,
                                             -VIEW_RATE_H,
                                             self.view.bounds.size.width,
                                             VIEW_RATE_H);
            viewRate = [[RateHelperView alloc] initWithFrame:frameRateViewHidden];
            viewRate.delegate = self;
            [self.view addSubview:viewRate];
            _labelInfo.text = @"RateHelper in action now.";
        } else {
            [[RateHelperSettings sharedSettings] decrementAskAfterNum];
            _labelInfo.text = [NSString stringWithFormat:@"RateHelper will be shown after\n\n%lu\n\nappears of 2-nd Screen", (unsigned long)[RateHelperSettings sharedSettings].askAfterN];
        }
    } else {
        _labelInfo.text = @"RateHelper will not be shown in this version. Change version manually in Info.plist or Reset settings";
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (viewRate) {
        if(!viewRate.wasOutsideApp) {
            // Init frames for main and rate views
            frameRateViewShown = CGRectMake(0,
                                            yTop,
                                            viewRate.bounds.size.width,
                                            viewRate.bounds.size.height);
            [UIView animateWithDuration:0.5
                             animations:^{
                                 viewRate.frame = frameRateViewShown;
                             }
                             completion:nil];
        } else {
            [viewRate showLastView];
            [self hideRateViewAfter:2.0];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(thankYouAndHideRate)
                                                 name:NOTIFY_APP_DID_BECOME_ACTIVE
                                               object:nil];
}


- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)thankYouAndHideRate
{
    if (viewRate.wasOutsideApp) {
        [viewRate showLastView];
        [self hideRateViewAfter:2.0];
    }
}


- (void)hideRateViewAfter:(CGFloat)delay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5
                         animations:^{
                             viewRate.frame = frameRateViewHidden;
                         }
                         completion:^(BOOL finished) {
                             viewRate = nil;
                             _labelInfo.text = @"That's all!";
                         }];
    });
}

#pragma mark - RateHelperViewDelegate -

- (void)rateView:(RateHelperView *)rateView pressed:(RateHelperViewButton)choose fromState:(RateHelperViewState)state
{
    BOOL hideRateView = NO;
    switch (state) {
        case RateHelperView_MainQuestion:
            if (choose == RateHelperViewButton_No) {
                // Add analytic event if you want to messure this event
            } else {
                // Add analytic event if you want to messure this event
            }
            break;
            
        case RateHelperView_FeedbackQuestion:
            if (choose == RateHelperViewButton_No) {
                // Add analytic event if you want to messure this event
                [rateView showLastView];
                hideRateView = YES;
            } else {
                // Add analytic event if you want to messure this event
                [self writeToDevelopers];
            }
            break;
            
        case RateHelperView_ReviewQuestion:
            if (choose == RateHelperViewButton_No) {
                // Add analytic event if you want to messure this event
                [rateView showLastView];
                hideRateView = YES;
            } else {
                // Add analytic event if you want to messure this event
            }
            break;
            
        default:
            break;
    }
    
    // Спрятать RateHelperView
    if (hideRateView) {
        [self hideRateViewAfter:2.0];
    }
}

- (void)writeToDevelopers
{
    // Implement your own Feedback call here
    
    // And hide RateHelperView after all
    [viewRate showLastView];
    [self hideRateViewAfter:2.0];
}


@end
