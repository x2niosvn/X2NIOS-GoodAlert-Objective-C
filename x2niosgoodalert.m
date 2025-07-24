#import "x2niosgoodalert.h"
#import <AudioToolbox/AudioToolbox.h>

static NSMutableArray *currentAlerts;
static const CGFloat kAlertWidth = 240.0f;
static const CGFloat kAlertHeight = 52.0f;
static const CGFloat kAnimationDuration = 0.3f;
static const NSTimeInterval kDefaultDuration = 3.0f;
static const CGFloat kAlertSpacing = 8.0f;
static const CGFloat kInitialTopMargin = 40.0f;
static const CGFloat kIconSize = 24.0f;
static const CGFloat kCircleWidth = 2.0f;
static const CGFloat kVerticalLineWidth = 3.0f;

@interface X2NiosGoodAlert ()
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *verticalLine;
@property (nonatomic, assign) BOOL shouldVibrate;
@end

@implementation X2NiosGoodAlert

+ (void)initialize {
    if (self == [X2NiosGoodAlert class]) {
        currentAlerts = [NSMutableArray array];
    }
}

+ (void)showAlertWithType:(X2NiosAlertType)type message:(NSString *)message duration:(NSTimeInterval)duration shouldVibrate:(BOOL)shouldVibrate {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Calculate position for new alert
        CGFloat yPosition = kInitialTopMargin;
        if (currentAlerts.count > 0) {
            X2NiosGoodAlert *lastAlert = [currentAlerts lastObject];
            yPosition = CGRectGetMaxY(lastAlert.frame) + kAlertSpacing;
        }
        
        X2NiosGoodAlert *alert = [[X2NiosGoodAlert alloc] initWithType:type message:message];
        alert.identifier = [NSUUID UUID].UUIDString;
        alert.shouldVibrate = shouldVibrate;
        
        // Set initial position
        CGRect frame = alert.frame;
        frame.origin.y = yPosition;
        alert.frame = frame;
        
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        [window addSubview:alert];
        [currentAlerts addObject:alert];
        
        [alert animateIn];
        
        // Vibrate if needed
        if (shouldVibrate) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        
        if (type != X2NiosAlertTypeLoading) {
            [alert startProgressBarAnimation:duration];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissAlertWithIdentifier:alert.identifier];
            });
        }
    });
}

+ (void)adjustAlertPositions {
    __block CGFloat currentY = kInitialTopMargin;
    
    [UIView animateWithDuration:0.3 animations:^{
        for (X2NiosGoodAlert *alert in currentAlerts) {
            CGRect frame = alert.frame;
            frame.origin.y = currentY;
            alert.frame = frame;
            currentY = CGRectGetMaxY(frame) + kAlertSpacing;
        }
    }];
}

- (instancetype)initWithType:(X2NiosAlertType)type message:(NSString *)message {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake(screenBounds.size.width - kAlertWidth - 16,
                             40,
                             kAlertWidth,
                             kAlertHeight);
    
    self = [super initWithFrame:frame];
    if (self) {
        self.containerView = [[UIView alloc] initWithFrame:self.bounds];
        self.containerView.layer.cornerRadius = 10.0f;
        self.containerView.clipsToBounds = YES;
        [self addSubview:self.containerView];
        
        // Setup background color with slightly more transparency
        self.containerView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.75];
        
        // Setup icon and colors based on type
        NSString *iconName;
        NSString *titleText;
        UIColor *statusColor;
        
        switch (type) {
            case X2NiosAlertTypeSuccess:
                iconName = @"checkmark.circle.fill";
                titleText = @"Success";
                statusColor = [UIColor colorWithRed:76/255.0 green:175/255.0 blue:80/255.0 alpha:1.0];
                break;
            case X2NiosAlertTypeFail:
                iconName = @"xmark.circle.fill";
                titleText = @"Fail";
                statusColor = [UIColor colorWithRed:244/255.0 green:67/255.0 blue:54/255.0 alpha:1.0];
                break;
            case X2NiosAlertTypeWarn:
                iconName = @"exclamationmark.triangle.fill";
                titleText = @"Warning";
                statusColor = [UIColor colorWithRed:255/255.0 green:152/255.0 blue:0/255.0 alpha:1.0];
                break;
            case X2NiosAlertTypeInfo:
                iconName = @"info.circle.fill";
                titleText = @"Info";
                statusColor = [UIColor colorWithRed:33/255.0 green:150/255.0 blue:243/255.0 alpha:1.0];
                break;
            case X2NiosAlertTypeLoading:
                iconName = @"clock.fill";
                titleText = @"Loading";
                statusColor = [UIColor colorWithRed:158/255.0 green:158/255.0 blue:158/255.0 alpha:1.0];
                break;
        }
        
        // Add vertical line
        self.verticalLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kVerticalLineWidth, kAlertHeight)];
        self.verticalLine.backgroundColor = statusColor;
        [self.containerView addSubview:self.verticalLine];
        
        // Create circular progress layer - adjust x position for vertical line
        CGFloat iconCenterX = kVerticalLineWidth + 16 + kIconSize/2;
        CGFloat iconCenterY = kAlertHeight/2;
        UIBezierPath *circularPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(iconCenterX, iconCenterY)
                                                                   radius:(kIconSize/2 + 4)
                                                               startAngle:-M_PI_2
                                                                 endAngle:3*M_PI_2
                                                                clockwise:YES];
        
        self.progressLayer = [CAShapeLayer layer];
        self.progressLayer.path = circularPath.CGPath;
        self.progressLayer.strokeColor = statusColor.CGColor;
        self.progressLayer.fillColor = [UIColor clearColor].CGColor;
        self.progressLayer.lineWidth = kCircleWidth;
        self.progressLayer.strokeEnd = 1.0;
        self.progressLayer.lineCap = kCALineCapRound;
        [self.containerView.layer addSublayer:self.progressLayer];
        
        if (type == X2NiosAlertTypeLoading) {
            self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
            self.loadingIndicator.color = statusColor;
            self.loadingIndicator.center = CGPointMake(iconCenterX, iconCenterY);
            [self.loadingIndicator startAnimating];
            [self.containerView addSubview:self.loadingIndicator];
        } else if (@available(iOS 13.0, *)) {
            UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:kIconSize weight:UIImageSymbolWeightMedium];
            UIImage *icon = [UIImage systemImageNamed:iconName withConfiguration:configuration];
            self.iconImageView = [[UIImageView alloc] initWithImage:icon];
            self.iconImageView.tintColor = statusColor;
            self.iconImageView.frame = CGRectMake(kVerticalLineWidth + 16, (kAlertHeight - kIconSize)/2, kIconSize, kIconSize);
            [self.containerView addSubview:self.iconImageView];
        }
        
        // Setup title label - adjust x position for vertical line
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kVerticalLineWidth + 52, 8, kAlertWidth - 64, 18)];
        self.titleLabel.text = titleText;
        self.titleLabel.textColor = [UIColor whiteColor];
        if (@available(iOS 13.0, *)) {
            self.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        }
        [self.containerView addSubview:self.titleLabel];
        
        // Setup message label - adjust x position for vertical line
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(kVerticalLineWidth + 52, 28, kAlertWidth - 64, 16)];
        self.messageLabel.text = message;
        self.messageLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        if (@available(iOS 13.0, *)) {
            self.messageLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        }
        [self.containerView addSubview:self.messageLabel];
        
        // Add shadow
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 4);
        self.layer.shadowRadius = 12;
        self.layer.shadowOpacity = 0.3;
    }
    return self;
}

- (void)startProgressBarAnimation:(NSTimeInterval)duration {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @1.0;
    animation.toValue = @0.0;
    animation.duration = duration;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [self.progressLayer addAnimation:animation forKey:@"circularProgress"];
}

- (void)animateIn {
    self.alpha = 0;
    self.transform = CGAffineTransformMakeTranslation(30, 0);
    
    [UIView animateWithDuration:kAnimationDuration
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)animateOutWithCompletion:(void(^)(void))completion {
    NSInteger index = [currentAlerts indexOfObject:self];
    [currentAlerts removeObject:self];
    
    [UIView animateWithDuration:kAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeTranslation(30, 0);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
        // Only adjust positions if there are remaining alerts
        if (currentAlerts.count > 0 && index != NSNotFound) {
            __block CGFloat currentY = kInitialTopMargin;
            
            // If not the first alert, calculate Y based on previous alert
            if (index > 0 && index - 1 < currentAlerts.count) {
                X2NiosGoodAlert *previousAlert = currentAlerts[index - 1];
                currentY = CGRectGetMaxY(previousAlert.frame) + kAlertSpacing;
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                // Only adjust alerts that come after the removed one
                for (NSInteger i = index; i < currentAlerts.count; i++) {
                    X2NiosGoodAlert *alert = currentAlerts[i];
                    CGRect frame = alert.frame;
                    frame.origin.y = currentY;
                    alert.frame = frame;
                    currentY = CGRectGetMaxY(frame) + kAlertSpacing;
                }
            }];
        }
        
        if (completion) completion();
    }];
}

// Convenience methods with vibration
+ (void)showSuccess:(NSString *)message shouldVibrate:(BOOL)shouldVibrate {
    [self showAlertWithType:X2NiosAlertTypeSuccess message:message duration:kDefaultDuration shouldVibrate:shouldVibrate];
}

+ (void)showFail:(NSString *)message shouldVibrate:(BOOL)shouldVibrate {
    [self showAlertWithType:X2NiosAlertTypeFail message:message duration:kDefaultDuration shouldVibrate:shouldVibrate];
}

+ (void)showWarn:(NSString *)message shouldVibrate:(BOOL)shouldVibrate {
    [self showAlertWithType:X2NiosAlertTypeWarn message:message duration:kDefaultDuration shouldVibrate:shouldVibrate];
}

+ (void)showInfo:(NSString *)message shouldVibrate:(BOOL)shouldVibrate {
    [self showAlertWithType:X2NiosAlertTypeInfo message:message duration:kDefaultDuration shouldVibrate:shouldVibrate];
}

+ (void)showLoading:(NSString *)message shouldVibrate:(BOOL)shouldVibrate {
    [self showAlertWithType:X2NiosAlertTypeLoading message:message duration:0 shouldVibrate:shouldVibrate];
}

// Default methods without vibration
+ (void)showSuccess:(NSString *)message {
    [self showSuccess:message shouldVibrate:NO];
}

+ (void)showFail:(NSString *)message {
    [self showFail:message shouldVibrate:NO];
}

+ (void)showWarn:(NSString *)message {
    [self showWarn:message shouldVibrate:NO];
}

+ (void)showInfo:(NSString *)message {
    [self showInfo:message shouldVibrate:NO];
}

+ (void)showLoading:(NSString *)message {
    [self showLoading:message shouldVibrate:NO];
}

+ (void)dismiss {
    if (currentAlerts.count > 0) {
        X2NiosGoodAlert *lastAlert = [currentAlerts lastObject];
        [self dismissAlertWithIdentifier:lastAlert.identifier];
    }
}

+ (void)dismissAlertWithIdentifier:(NSString *)identifier {
    // Create a copy of the array to avoid mutation while enumerating
    NSArray *alerts = [currentAlerts copy];
    for (X2NiosGoodAlert *alert in alerts) {
        if ([alert.identifier isEqualToString:identifier]) {
            [alert animateOutWithCompletion:nil];
            break;
        }
    }
}

+ (void)dismissAllAlerts {
    // Create a copy of the array to avoid mutation while enumerating
    NSArray *alerts = [currentAlerts copy];
    for (X2NiosGoodAlert *alert in alerts) {
        [alert animateOutWithCompletion:nil];
    }
}

@end 