#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, X2NiosAlertType) {
    X2NiosAlertTypeSuccess,
    X2NiosAlertTypeFail,
    X2NiosAlertTypeWarn,
    X2NiosAlertTypeInfo,
    X2NiosAlertTypeLoading
};

typedef NS_ENUM(NSInteger, X2NiosAlertState) {
    X2NiosAlertStateOn,
    X2NiosAlertStateOff
};

@interface X2NiosGoodAlert : UIView

@property (nonatomic, assign) X2NiosAlertState state;
@property (nonatomic, copy) NSString *identifier;

+ (void)showAlertWithType:(X2NiosAlertType)type
                 message:(NSString *)message
               duration:(NSTimeInterval)duration
             shouldVibrate:(BOOL)shouldVibrate;

+ (void)showSuccess:(NSString *)message shouldVibrate:(BOOL)shouldVibrate;
+ (void)showFail:(NSString *)message shouldVibrate:(BOOL)shouldVibrate;
+ (void)showWarn:(NSString *)message shouldVibrate:(BOOL)shouldVibrate;
+ (void)showInfo:(NSString *)message shouldVibrate:(BOOL)shouldVibrate;
+ (void)showLoading:(NSString *)message shouldVibrate:(BOOL)shouldVibrate;

// Convenience methods with default vibration (NO)
+ (void)showSuccess:(NSString *)message;
+ (void)showFail:(NSString *)message;
+ (void)showWarn:(NSString *)message;
+ (void)showInfo:(NSString *)message;
+ (void)showLoading:(NSString *)message;

+ (void)dismiss;
+ (void)dismissAlertWithIdentifier:(NSString *)identifier;
+ (void)dismissAllAlerts;

@end 