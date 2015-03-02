#import <UIKit/UIKit.h>

// 1-ая фраза
#define kQuestion1 @"kQuestion1"
#define kQuestion1_no @"kQuestion1_no"
#define kQuestion1_yes @"kQuestion1_yes"
// 2-ая фраза об обратной связи
#define kQuestion2bad @"kQuestion2bad"
#define kQuestion2bad_no @"kQuestion2bad_no"
#define kQuestion2bad_yes @"kQuestion2bad_yes"
// 2-ая фраза об отзыве
#define kQuestion2good @"kQuestion2good"
#define kQuestion2good_no @"kQuestion2good_no"
#define kQuestion2good_yes @"kQuestion2good_yes"
// 3-я фраза
#define kPharase3 @"kPharase3"

#define NOTIFY_APP_DID_BECOME_ACTIVE @"NOTIFY_APP_DID_BECOME_ACTIVE"
#define kRateHelperSettings @"kRateHelperSettings"

typedef enum {
    RateHelperResolution_UNDEF=0,
    RateHelperResolution_Like,
    RateHelperResolution_Dislike
} RateHelperResolution;

typedef enum {
    RateHelperAction_UNDEF=0,
    RateHelperAction_Skip,
    RateHelperAction_Feedback,
    RateHelperAction_Review
} RateHelperAction;


@interface RateHelperSettings : NSObject

// PREDEFINED OPTIONS
@property (strong) NSString *appName;
@property (strong) UIFont *fontText;
@property (strong) UIFont *fontLeftBtn;
@property (strong) UIFont *fontRightBtn;
@property (strong) UIColor *colorText;
@property (strong) UIColor *colorBackgroundMain;
@property (strong) UIColor *colorBackgroundFeedback;
@property (strong) UIColor *colorBackgroundReview;
@property (assign) NSUInteger countDefaultAskAfter;
@property (strong) NSString *appIdentifier;

@property (assign, readonly) BOOL isActual;
@property (assign, readonly) NSUInteger askAfterN;


+ (RateHelperSettings *)sharedSettings;
- (void)initSettings;

- (void)decrementAskAfterNum;
- (void)saveResolution:(RateHelperResolution)resolution;
- (void)saveAction:(RateHelperAction)action;
- (void)resetAskAfter;
- (NSDictionary *)localizedStrings;

@end
