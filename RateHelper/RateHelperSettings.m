#import "RateHelperSettings.h"

#define DEFAULT_ASK_AFTER_NUM 10

#define kVersionCurrent @"kVersionCurrent"
#define kVersionLast @"kVersionLast"
#define kAskAfter @"kAskAfter"
#define kResolution @"kResolution"
#define kAction @"kAction"

@interface RateHelperSettings ()
{
    NSMutableDictionary *dictSettings;
    NSString *versionCurrent;
}

@property (assign) BOOL isActual;
@property (assign) NSUInteger askAfterN;

@end


@implementation RateHelperSettings

+ (RateHelperSettings *)sharedSettings
{
    static RateHelperSettings *_sharedSettings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSettings = [[RateHelperSettings alloc] init];
    });
    
    return _sharedSettings;
}


- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }

    // Default settings
    _appName = @"\"YOUR_APP_NAME\"";
    _countDefaultAskAfter = DEFAULT_ASK_AFTER_NUM;
    _fontText = _fontLeftBtn = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
    _fontRightBtn = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
    _colorText = [UIColor blackColor];
    _colorBackgroundMain = _colorBackgroundFeedback = _colorBackgroundReview = [UIColor whiteColor];
    
    return self;
}

- (void)initSettings
{
    NSDictionary *dictTmp = [[NSUserDefaults standardUserDefaults] objectForKey:kRateHelperSettings];
    NSString *versionApp = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    if (dictTmp) {
        dictSettings = [NSMutableDictionary dictionaryWithDictionary:dictTmp];
        NSString *versionFromSettings = dictSettings[kVersionCurrent];
        // Произошло обновление
        if (![versionApp isEqualToString:versionFromSettings]) {
            // Перезаписываем версии
            dictSettings[kVersionLast] = versionFromSettings;
            dictSettings[kVersionCurrent] = versionApp;
            // Сбрасываем счетчик до вопроса
            _askAfterN = _countDefaultAskAfter;
            [self saveAll];
        } else {
            // Берем сохраненное значение
            NSNumber *numAskAfter = dictSettings[kAskAfter];
            if (numAskAfter) {
                _askAfterN = [numAskAfter intValue];
            }
        }
    } else {
        _askAfterN = _countDefaultAskAfter;
        dictSettings = [NSMutableDictionary dictionary];
        dictSettings[kVersionCurrent] = versionApp;
        [self saveAll];
    }
    versionCurrent = versionApp;
    
    // Актуальность вопроса
    NSDictionary *dictCurrent = dictSettings[versionCurrent];
    NSNumber *numResolution = dictCurrent[kResolution];
    NSNumber *numAction = dictCurrent[kAction];
    if (!numAction || !numResolution) {
        _isActual = YES;
    }
}


#pragma mark - Modifications -

- (void)decrementAskAfterNum
{
    if (_askAfterN > 0) {
        _askAfterN--;
        [self saveAll];
    }
}


- (void)resetAskAfter
{
    _askAfterN = _countDefaultAskAfter;
    [self saveAll];
}

// Сохранить Нравится / Не нравится для текущей версии
- (void)saveResolution:(RateHelperResolution)resolution
{
    if (versionCurrent.length > 0) {
        NSDictionary *dictCurrent = dictSettings[versionCurrent];
        NSMutableDictionary *dictCurrentNew = [NSMutableDictionary dictionaryWithDictionary:dictCurrent];
        dictCurrentNew[kResolution] = [NSNumber numberWithInt:resolution];
        dictSettings[versionCurrent] = dictCurrentNew;
        [self saveAll];
    }
}

// Сохранить действие (Пропуск, Email, Review) для текущей версии
- (void)saveAction:(RateHelperAction)action
{
    if (versionCurrent.length > 0) {
        NSDictionary *dictCurrent = dictSettings[versionCurrent];
        NSMutableDictionary *dictCurrentNew = [NSMutableDictionary dictionaryWithDictionary:dictCurrent];
        dictCurrentNew[kAction] = [NSNumber numberWithInt:action];
        dictSettings[versionCurrent] = dictCurrentNew;
        [self saveAll];
        // В этой версии больше не актуально спрашивать
        _isActual = NO;
    }
}


- (void)saveAll
{
    dictSettings[kAskAfter] = [NSNumber numberWithInteger:_askAfterN];
    [[NSUserDefaults standardUserDefaults] setObject:dictSettings forKey:kRateHelperSettings];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSDictionary *)localizedStrings
{
    // 1-ая фраза
    NSString *question1Format = [self localizedStringForKey:@"RateHelperQuestion1" withDefault:@""];
    NSString *question1_no = [self localizedStringForKey:@"RateHelperQuestion1_No" withDefault:@""];
    NSString *question1_yes = [self localizedStringForKey:@"RateHelperQuestion1_Yes" withDefault:@""];
    NSString *lastVersion = dictSettings[kVersionLast];
    NSDictionary *dictResolutionLast = dictSettings[lastVersion];
    NSNumber *resolutionLast = dictResolutionLast[kResolution];
    if (resolutionLast) {
        switch ([resolutionLast intValue]) {
            case RateHelperResolution_Dislike:
                question1Format = [self localizedStringForKey:@"RateHelperQuestion1_After_Bad" withDefault:@""];
                break;

            case RateHelperResolution_Like:
            default:
                question1Format = [self localizedStringForKey:@"RateHelperQuestion1_After_Good" withDefault:@""];
                break;
        }
    }
    NSString *question1 = [NSString stringWithFormat:question1Format, _appName];
    
    // 2-ая фраза об обратной связи
    NSString *question2_bad = [self localizedStringForKey:@"RateHelperQuestion1_Bad" withDefault:@""];
    NSString *question2_bad_no = [self localizedStringForKey:@"RateHelperQuestion1_Bad_No" withDefault:@""];
    NSString *question2_bad_yes = [self localizedStringForKey:@"RateHelperQuestion1_Bad_Yes" withDefault:@""];

    // 2-ая фраза об отзыве
    NSString *question2_good = [self localizedStringForKey:@"RateHelperQuestion1_Good" withDefault:@""];
    NSString *question2_good_no = [self localizedStringForKey:@"RateHelperQuestion1_Good_No" withDefault:@""];
    NSString *question2_good_yes = [self localizedStringForKey:@"RateHelperQuestion1_Good_Yes" withDefault:@""];
    
    // 3-я фраза
    NSString *phrase3 = [self localizedStringForKey:@"RateHelperPhrase3" withDefault:@""];
    
    NSDictionary *result = @{kQuestion1: question1,
                             kQuestion1_no: question1_no,
                             kQuestion1_yes: question1_yes,
                             
                             kQuestion2bad: question2_bad,
                             kQuestion2bad_no: question2_bad_no,
                             kQuestion2bad_yes: question2_bad_yes,
                             
                             kQuestion2good: question2_good,
                             kQuestion2good_no: question2_good_no,
                             kQuestion2good_yes: question2_good_yes,
                             
                             kPharase3: phrase3};
    return result;
}

- (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString
{
    static NSBundle *bundle = nil;
    if (bundle == nil)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"RateHelper" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *language = [[NSLocale preferredLanguages] count]? [NSLocale preferredLanguages][0]: @"en";
        if (![[bundle localizations] containsObject:language])
        {
            language = [language componentsSeparatedByString:@"-"][0];
        }
        if ([[bundle localizations] containsObject:language])
        {
            bundlePath = [bundle pathForResource:language ofType:@"lproj"];
        }
        bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
    }
    defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];
}

@end
