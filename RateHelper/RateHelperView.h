#import <UIKit/UIKit.h>
#import "RateHelperSettings.h"

typedef enum {
    RateHelperView_UNDEF=0,
    RateHelperView_MainQuestion,
    RateHelperView_FeedbackQuestion,
    RateHelperView_ReviewQuestion,
    RateHelperView_LastMessage
} RateHelperViewState;

typedef enum {
    RateHelperViewButton_UNDEF=0,
    RateHelperViewButton_No,
    RateHelperViewButton_Yes
} RateHelperViewButton;

@class RateHelperView;

@protocol RateHelperViewDelegate <NSObject>
- (void)rateView:(RateHelperView *)rateView pressed:(RateHelperViewButton)choose fromState:(RateHelperViewState)state;
@end

@interface RateHelperView : UIView

@property (assign,readonly) BOOL wasOutsideApp;
@property (assign,readonly) RateHelperViewState stateView;
@property (strong) id<RateHelperViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)showLastView;

@end
