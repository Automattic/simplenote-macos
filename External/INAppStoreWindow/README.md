## INAppStoreWindow: Mac App Store style NSWindow subclass

INAppStoreWindow is an NSWindow subclass that mimics the appearance of the main window in the Mac App Store application. These modifications consist of enlarging the title bar, and centering the traffic lights (**note that this subclass does not handle the creation of a toolbar**). The end result looks like this:

![INAppStoreWindow](http://i41.tinypic.com/abidd1.png)

**Features of INAppStoreWindow:**

* No use of private APIs, so it's App Store friendly!
* The title bar view is entirely customizable -- you can add subviews (toolbars, buttons, etc.) as well as customize the title bar itself to give it a different appearance
* The height of the title bar is easily adjustable
* Default `NSWindow` traffic light buttons appearance customization
* Window's title appearance customization
* Compiles and runs perfectly under ARC and non-ARC setups (thanks to [@kgn](https://github.com/kgn))
* Support's Lion's full screen mode

## Usage

### Basic Configuration

Using `INAppStoreWindow` is as easy as changing the class of the `NSWindow` in Interface Builder, or simply by creating an instance of `INAppStoreWindow` in code (if you're doing it programmatically). I've included a sample project demonstrating how to use `INAppStoreWindow`.

**NOTE: The title bar height is set to the standard window title height by default. You must set the 'titleBarHeight' property in order to increase the height of the title bar.**

Some people seem to be having an issue where the title bar height property is not set properly when calling the method on an NSWindow without typecasting it to the INAppStoreWindow class. If you are experiencing this issue, do something like this (using a window controller, for example):

``` obj-c
INAppStoreWindow *aWindow = (INAppStoreWindow*)[windowController window];
aWindow.titleBarHeight = 60.0;
```

### Adding buttons and other controls to the title bar

Adding controls and other views to the title bar is simple. This can be done either programmatically or through Interface Builder. Here are examples of both methods:

**Programmatically**

``` obj-c
// This code places a 100x100 button in the center of the title bar view
NSView *titleBarView = self.window.titleBarView;
NSSize buttonSize = NSMakeSize(100.f, 100.f);
NSRect buttonFrame = NSMakeRect(NSMidX(titleBarView.bounds) - (buttonSize.width / 2.f), NSMidY(titleBarView.bounds) - (buttonSize.height / 2.f), buttonSize.width, buttonSize.height);
NSButton *button = [[NSButton alloc] initWithFrame:buttonFrame];
[button setTitle:@"A Button"];
[titleBarView addSubview:button];
```

**Interface Builder**

**NOTE:** Even though the content layout for the title bar can be done in Interface Builder, you still need to use the below code to display the view created in IB in the title bar.

``` obj-c
// self.titleView is a an IBOutlet to an NSView that has been configured in IB with everything you want in the title bar
self.titleView.frame = self.window.titleBarView.bounds;
self.titleView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
[self.window.titleBarView addSubview:self.titleView];
```

### Centering the traffic light and full screen buttons

The vertical centering of the traffic light and full screen buttons can be controlled through two properties: `centerTrafficLightButtons` and `centerFullScreenButton`.

The traffic light buttons are vertically centered by default.

### Hiding the title bar in fullscreen

You can tell INAppStoreWindow to hide when entering fullscreen mode, and reappear on exit. Just set the property `hideTitleBarInFullScreen`in order to hide it.

### Padding the traffic lights and fullscreen buttons

The left padding of the traffic lights can be adjusted with `trafficLightButtonsLeftMargin` and the right padding of the fullscreen button can be adjusted with `fullScreenButtonRightMargin`.

### Hiding the baseline (divider line between the titlebar and the content view)

The baseline divider can be hidden by setting `showsBaselineSeparator` to `NO`, the default value is `YES`.

### Customizing traffic lights buttons

In order to customize these buttons, you would use `INWindowButton` class. You must create a separate instance for each button and provide your graphics for each state of the button. Currently the following states are supported:

* Active
* Active in not main window
* Inactive (disabled)
* Rollover
* Pressed

Please refer to `INWindowButton.h` header documentation for more details.

### Customizing window's title appearance

You can enable title drawing by setting `showsTitle` property to `YES`. You can adjust appearance using `titleTextColor`, `inactiveTitleTextColor`, `titleTextShadow`, and `inactiveTitleTextShadow` properties. Also, you can enable title drawing in fullscreen by setting `showsTitleInFullscreen` property to `YES`.

### Using your own drawing code

A lot of time and effort has gone into making the custom titlebar in INAppStoreWindow function just right, it would be a shame to have to re-implement all this work just to draw your own custom title bar. So INAppStoreWindow has a `titleBarDrawingBlock` property that can be set to a block containing your own drawing code!

[![](http://dribbble.com/system/assets/2398/7253/screenshots/541256/notepad.png)](http://dribbble.com/shots/541256-Notepad-App-Mockup)

```obj-c
[self.window setTitleBarDrawingBlock:^(BOOL drawsAsMainWindow, CGRect drawingRect, CGPathRef clippingPath){
    // Custom drawing code!    
}];
```

This block gets passed some useful parameters like if the window is the main one(`drawsAsMainWindow`), the drawing rect of the title bar(`drawingRect`), and a pre-made clipping path with rounded corners at the top(`clippingPath`).

### Setting the title bar colors

If you just want to adjust the color of the title bar without drawing the whole thing yourself, there are a few properties to help you do so:

```obj-c
self.window.titleBarStartColor     = [NSColor colorWithCalibratedWhite: 0.6 alpha: 1.0];
self.window.titleBarEndColor       = [NSColor colorWithCalibratedWhite: 0.9 alpha: 1.0];
self.window.baselineSeparatorColor = [NSColor colorWithCalibratedWhite: 0.2 alpha: 1.0];

self.window.inactiveTitleBarEndColor       = [NSColor colorWithCalibratedWhite: 0.95 alpha: 1.0];
self.window.inactiveTitleBarStartColor     = [NSColor colorWithCalibratedWhite: 0.8  alpha: 1.0];
self.window.inactiveBaselineSeparatorColor = [NSColor colorWithCalibratedWhite: 0.4  alpha: 1.0];
```


## Authors

INAppStoreWindow is maintained by [Indragie Karunaratne](http://indragie.com) and [David Keegan](http://inscopeapps.com). Special thanks to [everyone else](https://github.com/indragiek/INAppStoreWindow/contributors) who contributed various fixes and improvements to the code.

## Licensing

INAppStoreWindow is licensed under the [BSD license](http://www.opensource.org/licenses/bsd-license.php).
