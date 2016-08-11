//
//  INWindowButton.h
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

#import <Cocoa/Cocoa.h>

/**
 A concrete NSButton subclass that allows to mimic standard window title bar "traffic light" buttons
 and replace their graphics with custom ones.
 */
@interface INWindowButton : NSButton

/**
 A group identifier the receiver was initialized with.
 */
@property (nonatomic, copy, readonly) NSString *groupIdentifier;

/**
 An image for the normal state.
 */
@property (nonatomic, strong) NSImage *activeImage;

/**
 An image for the normal state, but displayed when receiver's window in not a key.
 */
@property (nonatomic, strong) NSImage *activeNotKeyWindowImage;

/**
 An image used in disabled state.
 */
@property (nonatomic, strong) NSImage *inactiveImage;

/**
 An image used when user hovers receiver with mouse pointer.
 */
@property (nonatomic, strong) NSImage *rolloverImage;

/**
 An image for the pressed state.
 */
@property (nonatomic, strong) NSImage *pressedImage;

/**
 @param size Designated size of the button. System size is 14x16 and you are considered to use it.
 @param groupIdentifier ID of the group which will apply rollover effect to it's members. You may pass `nil`.
 @see initWithSize:groupIdentifier:
 */
+ (instancetype)windowButtonWithSize:(NSSize)size groupIdentifier:(NSString *)groupID;

/**
 @abstract Designated initializer.
 @discussion Initializes receiver with the given size and includes it to the group with the given identifier.
 Groups are used to apply rollover effect to all buttons that are inside the same group.
 E.g. close, minimize and zoom buttons should be inside the same group since they all get rollover effect
 when mouse pointer points to one of these buttons.
 @param size Designated size of the button. System size is 14x16 and you are considered to use it.
 @param groupIdentifier ID of the group which will apply rollover effect to it's members. You may pass `nil`.
 */
- (instancetype)initWithSize:(NSSize)size groupIdentifier:(NSString *)groupIdentifier;

@end
