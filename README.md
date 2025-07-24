# X2NiosAlert

A beautiful, modern and customizable alert library for iOS with Material Design inspiration.

![Success Alert](screenshots/success.png)
![Loading Alert](screenshots/loading.png)

## Features

- 🎨 Beautiful Material Design inspired alerts
- 🌈 Multiple alert types (Success, Fail, Warning, Info, Loading)
- ⚡️ Smooth animations and transitions
- 📱 Haptic feedback support
- ⏱ Customizable duration with progress indicator
- 🔄 Loading state with activity indicator
- 🎯 Multiple alerts stacking
- 🎭 Dark theme optimized
- 📐 Pixel-perfect design

## Requirements

- iOS 13.0+
- Xcode 11+
- Objective-C

## Installation

### Manual Installation

1. Download the X2NiosAlert folder
2. Drag and drop `x2niosgoodalert.h` and `x2niosgoodalert.m` into your Xcode project
3. Make sure to check "Copy items if needed" and select your target

## Usage

### Import

```objective-c
#import "x2niosgoodalert.h"
```

### Basic Usage

```objective-c
// Success Alert
[X2NiosGoodAlert showSuccess:@"Operation successful!"];

// Fail Alert
[X2NiosGoodAlert showFail:@"Operation failed!"];

// Warning Alert
[X2NiosGoodAlert showWarn:@"Warning message"];

// Info Alert
[X2NiosGoodAlert showInfo:@"Information message"];

// Loading Alert
[X2NiosGoodAlert showLoading:@"Processing..."];

// Dismiss Loading
[X2NiosGoodAlert dismiss];
```

### With Haptic Feedback

```objective-c
// Success Alert with vibration
[X2NiosGoodAlert showSuccess:@"Operation successful!" shouldVibrate:YES];

// Fail Alert with vibration
[X2NiosGoodAlert showFail:@"Operation failed!" shouldVibrate:YES];

// Warning Alert with vibration
[X2NiosGoodAlert showWarn:@"Warning message" shouldVibrate:YES];

// Info Alert with vibration
[X2NiosGoodAlert showInfo:@"Information message" shouldVibrate:YES];

// Loading Alert with vibration
[X2NiosGoodAlert showLoading:@"Processing..." shouldVibrate:YES];
```

### Custom Duration

```objective-c
[X2NiosGoodAlert showAlertWithType:X2NiosAlertTypeSuccess 
                          message:@"Custom duration message" 
                         duration:5.0 
                   shouldVibrate:NO];
```

## Alert Types

- **Success**: Green alert with checkmark icon
- **Fail**: Red alert with X icon
- **Warning**: Orange alert with exclamation icon
- **Info**: Blue alert with info icon
- **Loading**: Gray alert with activity indicator

## Features Details

### Progress Indicator
Each alert (except Loading) includes a circular progress indicator around the icon that shows the remaining time before the alert dismisses.

### Haptic Feedback
Optional vibration feedback when alerts appear, making them more noticeable.

### Alert Stacking
Multiple alerts stack vertically with proper spacing and animations.

### Auto Dismissal
Alerts automatically dismiss after a specified duration (default 3 seconds). Loading alerts require manual dismissal.

### Material Design
Follows Material Design principles with:
- Subtle shadows
- Color-coded status bar
- Smooth animations
- Modern typography
- Proper spacing

## Customization

The library includes several customizable constants:

```objective-c
static const CGFloat kAlertWidth = 240.0f;        // Alert width
static const CGFloat kAlertHeight = 52.0f;        // Alert height
static const CGFloat kAlertSpacing = 8.0f;        // Spacing between stacked alerts
static const CGFloat kVerticalLineWidth = 3.0f;   // Width of the status line
static const CGFloat kIconSize = 24.0f;           // Size of the status icon
```

## License

X2NiosAlert is available under the MIT license. See the LICENSE file for more info.

## Author

Created by X2NIOS

## Contributing

Feel free to submit pull requests, create issues or spread the word. 