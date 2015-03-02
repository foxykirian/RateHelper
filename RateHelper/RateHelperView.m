#import "RateHelperView.h"
#import "RateHelperSettings.h"

#define LABEL_H 50
#define BTN_H 40
#define OFFSET 10
#define TAG_NO 100
#define TAG_YES 101
#define DURATION 0.3

@interface RateHelperView ()
{
    UIView *viewFirst, *viewSecond, *viewThird;
    NSDictionary *dictStrings;
    CGRect frameAboveTop, frameBelowTop;
}

@property (assign) RateHelperViewState stateView;
@property (assign) BOOL wasOutsideApp;

@end

@implementation RateHelperView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    dictStrings = [[RateHelperSettings sharedSettings] localizedStrings];
    
    frameAboveTop = CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height);
    frameBelowTop = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    viewFirst = [[UIView alloc] initWithFrame:frameBelowTop];
    NSString *question1 = dictStrings[kQuestion1];
    NSString *no1 = dictStrings[kQuestion1_no];
    NSString *yes1 = dictStrings[kQuestion1_yes];
    [self disposeQuestionOnView:viewFirst color:[RateHelperSettings sharedSettings].colorBackgroundMain question:question1 no:no1 yes:yes1];
    [self addSubview:viewFirst];
    
    _stateView = RateHelperView_MainQuestion;
    
    return self;
}

- (void)disposeLabelOnView:(UIView *)subView color:(UIColor *)color title:(NSString *)title
{
    subView.backgroundColor = color;
    UILabel *labelTitle;
    UIFont *font = [RateHelperSettings sharedSettings].fontText;
    CGRect frameLabel = subView.bounds;
    labelTitle = [[UILabel alloc] initWithFrame:frameLabel];
    labelTitle.textColor = [RateHelperSettings sharedSettings].colorText;
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.font = font;
    labelTitle.text = title;
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.numberOfLines = 0;
    [subView addSubview:labelTitle];
    
    [self addSublineOn:subView withColor:labelTitle.textColor];
}


- (void)disposeQuestionOnView:(UIView *)subView color:(UIColor *)color question:(NSString *)question no:(NSString *)no yes:(NSString *)yes
{
    subView.backgroundColor = color;
    UIButton *btnNo, *btnYes;
//    UIFont *font = [UIFont fontWithName:MAIN_FONT_NAME size:17];
//    UIFont *fontBold = [UIFont fontWithName:MAIN_FONT_BOLD size:17];
    UIColor *colorBtnText = [RateHelperSettings sharedSettings].colorText;
    UIColor *colorBtnBorder = colorBtnText;
    UIColor *colorTextPressed = [UIColor lightGrayColor];
    CGRect frameLabel = CGRectMake(OFFSET, 0, self.bounds.size.width - OFFSET, LABEL_H);
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:frameLabel];
    labelTitle.textColor = [RateHelperSettings sharedSettings].colorText;
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.font = [RateHelperSettings sharedSettings].fontText;
    labelTitle.text = question;
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.numberOfLines = 0;
    [subView addSubview:labelTitle];
    
    CGFloat yBtn = self.bounds.size.height - OFFSET - BTN_H;
    CGFloat wBtn = (self.bounds.size.width - 4 * OFFSET)/2;
    CGRect frameBtn = CGRectMake(0, yBtn, wBtn, BTN_H);
    btnNo = [[UIButton alloc] initWithFrame:frameBtn];
    btnNo.tag = TAG_NO;
    [btnNo setTitleColor:colorBtnText forState:UIControlStateNormal];
    [btnNo setTitle:no forState:UIControlStateNormal];
    btnYes = [[UIButton alloc] initWithFrame:frameBtn];
    btnYes.tag = TAG_YES;
    [btnYes setTitleColor:color forState:UIControlStateNormal];
    [btnYes setTitle:yes forState:UIControlStateNormal];
    
    NSArray *buttons = @[btnNo, btnYes];
    for (UIButton *btn in buttons) {
        [btn addTarget:self action:@selector(pressedAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:colorTextPressed forState:UIControlStateHighlighted];
        btn.layer.cornerRadius = 5;
        if (btn == btnNo) {
            btn.layer.borderWidth = 1.0;
            btn.layer.borderColor = colorBtnBorder.CGColor;
            btn.layer.backgroundColor = color.CGColor;
        } else {
            btn.layer.backgroundColor = colorBtnBorder.CGColor;
        }
        [subView addSubview:btn];
    }
    btnNo.titleLabel.font = [RateHelperSettings sharedSettings].fontLeftBtn;
    btnYes.titleLabel.font = [RateHelperSettings sharedSettings].fontRightBtn;
    [self alignElements:buttons inFrame:self.bounds vertical:NO];
    [self alignElements:@[labelTitle, btnNo] inFrame:self.bounds vertical:YES];
    btnYes.frame = CGRectMake(btnYes.frame.origin.x,
                              btnNo.frame.origin.y,
                              btnYes.bounds.size.width,
                              btnYes.bounds.size.height);
    
    [self addSublineOn:subView withColor:colorBtnBorder];
}

- (void)addSublineOn:(UIView *)view withColor:(UIColor *)c
{
    CGFloat hLine = 1.0;
    CALayer *layerLine = [CALayer layer];
    layerLine.frame = CGRectMake(0, self.bounds.size.height - hLine, self.bounds.size.width, hLine);
    layerLine.backgroundColor = c.CGColor;
    [view.layer addSublayer:layerLine];

}

- (void)showLastView
{
    NSString *last = dictStrings[kPharase3];
    viewThird = [[UIView alloc] initWithFrame:frameAboveTop];
    [self disposeLabelOnView:viewThird
                       color:[RateHelperSettings sharedSettings].colorBackgroundMain
                       title:last];
    [self addSubview:viewThird];
    
    // Показ с анимацией
    [UIView animateWithDuration:DURATION
                     animations:^{
                         viewThird.frame = frameBelowTop;
                     }];
}

- (void)pressedAnswer:(UIButton *)btn
{
    BOOL agree = btn.tag == TAG_YES;
    NSString *question2;
    NSString *no2;
    NSString *yes2;
    UIColor *colorForView;
    // Отправка уведомления контроллеру
    if ([_delegate respondsToSelector:@selector(rateView:pressed:fromState:)]) {
        RateHelperViewButton choose = agree ? RateHelperViewButton_Yes : RateHelperViewButton_No;
        [_delegate rateView:self pressed:choose fromState:_stateView];
    }
    switch (_stateView) {
        case RateHelperView_MainQuestion:
        {
            if (agree) {
                question2 = dictStrings[kQuestion2good];
                no2 = dictStrings[kQuestion2good_no];
                yes2 = dictStrings[kQuestion2good_yes];
                colorForView = [RateHelperSettings sharedSettings].colorBackgroundReview;
                _stateView = RateHelperView_ReviewQuestion;
                [[RateHelperSettings sharedSettings] saveResolution:RateHelperResolution_Like];
            } else {
                question2 = dictStrings[kQuestion2bad];
                no2 = dictStrings[kQuestion2bad_no];
                yes2 = dictStrings[kQuestion2bad_yes];
                colorForView = [RateHelperSettings sharedSettings].colorBackgroundFeedback;
                _stateView = RateHelperView_FeedbackQuestion;
                [[RateHelperSettings sharedSettings] saveResolution:RateHelperResolution_Dislike];
            }
            viewSecond = [[UIView alloc] initWithFrame:frameAboveTop];
            [self disposeQuestionOnView:viewSecond
                                  color:colorForView
                               question:question2
                                     no:no2
                                    yes:yes2];
            [self addSubview:viewSecond];
            
            // Показ с анимацией
            [UIView animateWithDuration:DURATION
                             animations:^{
                                 viewSecond.frame = frameBelowTop;
                             }];
            break;
        }

        case RateHelperView_FeedbackQuestion:
            if (agree) {
                [[RateHelperSettings sharedSettings] saveAction:RateHelperAction_Feedback];
            } else {
                [[RateHelperSettings sharedSettings] saveAction:RateHelperAction_Skip];
            }
            break;

        case RateHelperView_ReviewQuestion:
            if (agree) {
                [[RateHelperSettings sharedSettings] saveAction:RateHelperAction_Review];
                [self writeReview];
            } else {
                [[RateHelperSettings sharedSettings] saveAction:RateHelperAction_Skip];
            }

            break;
    }
}


- (void)writeReview
{
    NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", [RateHelperSettings sharedSettings].appIdentifier];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    _wasOutsideApp = YES;
}


- (void)alignElements:(NSArray*)elements inFrame:(CGRect)inFrame vertical:(BOOL)vertical
{
    CGFloat summarySide = 0;
    
    for (UIView *element in elements) {
        summarySide += vertical ? element.frame.size.height : element.frame.size.width;
    }
    
    CGFloat yOffset = vertical ? (inFrame.size.height - summarySide) / ([elements count]+1) : 0;
    CGFloat xOffset = vertical ? 0 : (inFrame.size.width - summarySide) / ([elements count]+1);
    
    CGFloat x = xOffset;
    CGFloat y = yOffset;
    for (UIView *element in elements) {
        CGRect frameNew;
        if (vertical) {
            frameNew = CGRectMake(element.frame.origin.x,
                                  y,
                                  element.frame.size.width,
                                  element.frame.size.height);
            y += element.frame.size.height + yOffset;
        } else {
            frameNew = CGRectMake(x,
                                  element.frame.origin.y,
                                  element.frame.size.width,
                                  element.frame.size.height);
            x += element.frame.size.width + xOffset;
        }
        element.frame = frameNew;
    }
}

@end
