//
//  INWindowButton.m
//
//  Copyright 2013 Vladislav Alexeev. All rights reserved.
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
//  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
//  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "INWindowButton.h"

#pragma mark - Window Button Group

NSString *const INWindowButtonGroupDidUpdateRolloverStateNotification = @"INWindowButtonGroupDidUpdateRolloverStateNotification";
NSString *const kINWindowButtonGroupDefault = @"com.indragie.inappstorewindow.defaultWindowButtonGroup";

@interface INWindowButtonGroup : NSObject

+ (instancetype)groupWithIdentifier:(NSString *)identifier;
@property (nonatomic, copy, readonly) NSString *identifier;

- (void)didCaptureMousePointer;
- (void)didReleaseMousePointer;
- (BOOL)shouldDisplayRollOver;

- (void)resetMouseCaptures;

@end

@interface INWindowButtonGroup ()
@property (nonatomic, assign) NSInteger numberOfCaptures;
@end

@implementation INWindowButtonGroup

+ (instancetype)groupWithIdentifier:(NSString *)identifier {
    static NSMutableDictionary *groups = nil;
    if (groups == nil) {
        groups = [[NSMutableDictionary alloc] init];
    }
    
    if (identifier == nil) {
        identifier = kINWindowButtonGroupDefault;
    }
    
    INWindowButtonGroup *group = [groups objectForKey:identifier];
    if (group == nil) {
        group = [[[self class] alloc] initWithIdentifier:identifier];
        [groups setObject:group forKey:identifier];
    }
    return group;
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
    }
    return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_identifier release];
    [super dealloc];
}
#endif

- (void)setNumberOfCaptures:(NSInteger)numberOfCaptures {
    if (_numberOfCaptures != numberOfCaptures && numberOfCaptures >= 0) {
        _numberOfCaptures = numberOfCaptures;
        [[NSNotificationCenter defaultCenter] postNotificationName:INWindowButtonGroupDidUpdateRolloverStateNotification
                                                            object:self];
    }
}

- (void)didCaptureMousePointer {
    self.numberOfCaptures++;
}

- (void)didReleaseMousePointer {
    self.numberOfCaptures--;
}

- (BOOL)shouldDisplayRollOver {
    return (self.numberOfCaptures > 0);
}

- (void)resetMouseCaptures {
    self.numberOfCaptures = 0;
}

@end

#pragma mark - Window Button

@interface INWindowButton ()
@property (nonatomic, copy) NSString *groupIdentifier;
@property (nonatomic, strong, readonly) INWindowButtonGroup *group;
@property (nonatomic, strong) NSTrackingArea *mouseTrackingArea;

@end

@implementation INWindowButton

+ (instancetype)windowButtonWithSize:(NSSize)size groupIdentifier:(NSString *)groupID {
    INWindowButton *button = [[self alloc] initWithSize:size groupIdentifier:groupID];
    return button;
}

#pragma mark - Init and Dealloc

- (instancetype)initWithSize:(NSSize)size groupIdentifier:(NSString *)groupIdentifier
{
    self = [super initWithFrame:NSMakeRect(0, 0, size.width, size.height)];
    if (self) {
        _groupIdentifier = [groupIdentifier copy];
        [self setButtonType:NSMomentaryChangeButton];
        [self setBordered:NO];
        [self setTitle:@""];
        [self.cell setHighlightsBy:NSContentsCellMask];
        [self.cell setImageDimsWhenDisabled:NO];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(windowButtonGroupDidUpdateRolloverStateNotification:)
                                                     name:INWindowButtonGroupDidUpdateRolloverStateNotification
                                                   object:self.group];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    #if !__has_feature(objc_arc)
    [_activeImage release];
    [_inactiveImage release];
    [_activeNotKeyWindowImage release];
    [_rolloverImage release];
    [_groupIdentifier release];
    [super dealloc];
    #endif
}

#pragma mark - Group

- (INWindowButtonGroup *)group {
    return [INWindowButtonGroup groupWithIdentifier:self.groupIdentifier];
}

- (void)windowButtonGroupDidUpdateRolloverStateNotification:(NSNotification *)n {
    [self updateRollOverImage];
}

#pragma mark - Tracking Area

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    
    if (self.mouseTrackingArea) {
        [self removeTrackingArea:self.mouseTrackingArea];
    }
    
    self.mouseTrackingArea = [[NSTrackingArea alloc] initWithRect:NSInsetRect(self.bounds, -4, -4)
                                                          options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                            owner:self
                                                         userInfo:nil];
    
    [self addTrackingArea:self.mouseTrackingArea];
}

#pragma mark - Window State Handling

- (void)viewDidMoveToWindow {
    if (self.window) {
        [self updateImage];
    }
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    if (self.window) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:self.window];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:self.window];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillEnterFullScreenNotification object:self.window];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillExitFullScreenNotification object:self.window];
    }
    if (newWindow != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(windowDidChangeFocus:)
                                                     name:NSWindowDidBecomeKeyNotification
                                                   object:newWindow];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(windowDidChangeFocus:)
                                                     name:NSWindowDidResignKeyNotification
                                                   object:newWindow];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(windowWillEnterFullScreen:)
                                                     name:NSWindowWillEnterFullScreenNotification
                                                   object:newWindow];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(windowWillExitFullScreen:)
                                                     name:NSWindowWillExitFullScreenNotification
                                                   object:newWindow];
    }
}

- (void)windowDidChangeFocus:(NSNotification *)n {
    [self updateImage];
}

- (void)windowWillEnterFullScreen:(NSNotification *)n {
    [self.group resetMouseCaptures];
    [self setHidden:YES];
}

- (void)windowWillExitFullScreen:(NSNotification *)n {
    [self.group resetMouseCaptures];
    [self setHidden:NO];
}

#pragma mark - Event Handling

- (void)viewDidEndLiveResize {
    [super viewDidEndLiveResize];
    [self.group resetMouseCaptures];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    [self.group didCaptureMousePointer];
    [self updateRollOverImage];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    [self.group didReleaseMousePointer];
    [self updateRollOverImage];
}

#pragma mark - Button Appearance

- (void)setPressedImage:(NSImage *)pressedImage {
    self.alternateImage = pressedImage;
}

- (NSImage *)pressedImage {
    return self.alternateImage;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (enabled) {
        self.image = self.activeImage;
    } else {
        self.image = self.inactiveImage;
    }
}

- (void)updateRollOverImage {
    if ([self.group shouldDisplayRollOver] && [self isEnabled]) {
        self.image = self.rolloverImage;
    } else {
        [self updateImage];
    }
}

- (void)updateImage {
    if ([self isEnabled]) {
        [self updateActiveImage];
    } else {
        self.image = self.inactiveImage;
    }
}

- (void)updateActiveImage {
    if ([self.window isKeyWindow]) {
        self.image = self.activeImage;
    } else {
        self.image = self.activeNotKeyWindowImage;
    }
}

@end
