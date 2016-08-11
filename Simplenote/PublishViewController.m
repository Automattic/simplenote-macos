//
//  PublishViewController.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 5/1/15.
//  Copyright (c) 2015 Simperium. All rights reserved.
//

#import "PublishViewController.h"
#import "VSThemeManager.h"
#import "VSTheme+Simplenote.h"



static CGFloat const SPLegendLineSize       = 13.0f;
static CGFloat const SPLegendLineSpacing    = 3.0f;


@interface PublishViewController ()
@property (nonatomic, strong) IBOutlet NSTextField  *urlTextField;
@property (nonatomic, strong) IBOutlet NSButton     *publishButton;
@property (nonatomic, strong) IBOutlet NSTextField  *legendTextField;
@end

@implementation PublishViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applyStyle)
                                                 name:VSThemeManagerThemeDidChangeNotification
                                               object:nil];
    
    [self applyStyle];
}

- (void)applyStyle
{
    NSAssert(self.urlTextField, @"Missing Outlet");
    NSAssert(self.publishButton, @"Missing Outlet");
    NSAssert(self.legendTextField, @"Missing Outlet");
    
    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    NSString *searchPlaceholder = NSLocalizedString(@"Not Published", @"Placeholder displayed when a note hasn't been published.");
    
    NSDictionary *urlAttributes = @{
        NSForegroundColorAttributeName  : [theme colorForKey:@"popoverTextColor"],
        NSFontAttributeName             : [theme fontForKey:@"popoverTextFont"]
    };
    
    if ([self.urlTextField respondsToSelector:@selector(setPlaceholderAttributedString:)]) {
        self.urlTextField.placeholderAttributedString = [[NSAttributedString alloc] initWithString:searchPlaceholder
                                                                                        attributes:urlAttributes];
    }
    
    self.urlTextField.backgroundColor = [theme colorForKey:@"shareUrlBackgroundColor"];
    
    // Legend
    NSMutableParagraphStyle *legendParagraph    = [[NSMutableParagraphStyle alloc] init];
    legendParagraph.lineSpacing                 = SPLegendLineSpacing;
    legendParagraph.minimumLineHeight           = SPLegendLineSize;
    legendParagraph.maximumLineHeight           = SPLegendLineSize;
    
    NSDictionary *legendAttributes = @{
        NSFontAttributeName                 : [theme fontForKey:@"popoverTextFont"],
        NSForegroundColorAttributeName      : [theme colorForKey:@"popoverTextColor"],
        NSParagraphStyleAttributeName       : legendParagraph
    };

    NSString *legend = NSLocalizedString(@"Publish this note to a web page. The page will stay updated with the contents of your note.", nil);
    self.legendTextField.attributedStringValue = [[NSAttributedString alloc] initWithString:legend attributes:legendAttributes];
}

@end
