//
//  SPMarkdownParser.m
//  Simplenote
//
//  Created by James Frost on 01/10/2015.
//  Copyright © 2015 Automattic. All rights reserved.
//

#import "SPMarkdownParser.h"
#import "html.h"
#import "SPTextView.h"
#import "Simplenote-Swift.h"

@implementation SPMarkdownParser

+ (NSString *)renderHTMLFromMarkdownString:(NSString *)markdown
{
    hoedown_renderer *renderer = hoedown_html_renderer_new(
                                                           HOEDOWN_HTML_SKIP_HTML |
                                                           HOEDOWN_HTML_USE_TASK_LIST,
                                                           0);
    hoedown_document *document = hoedown_document_new(
                                                      renderer,
                                                      HOEDOWN_EXT_AUTOLINK |
                                                      HOEDOWN_EXT_FENCED_CODE |
                                                      HOEDOWN_EXT_FOOTNOTES |
                                                      HOEDOWN_EXT_TABLES |
                                                      HOEDOWN_EXT_SPAN ,
                                                      16, 0, NULL, NULL);
    hoedown_buffer *html = hoedown_buffer_new(16);
    
    NSData *markdownData = [markdown dataUsingEncoding:NSUTF8StringEncoding];
    hoedown_document_render(document, html, markdownData.bytes, markdownData.length);
    
    NSData *htmlData = [NSData dataWithBytes:html->data length:html->size];
    
    hoedown_buffer_free(html);
    hoedown_document_free(document);
    hoedown_html_renderer_free(renderer);
    
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];

    return [[[self htmlHeader] stringByAppendingString:htmlString] stringByAppendingString:[self htmlFooter]];
}

+ (NSString *)htmlHeader
{
    NSString *headerStart =
        @"<html><head>"
            "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
            "<link href=\"https://fonts.googleapis.com/css?family=Noto+Serif\" rel=\"stylesheet\">"
            "<style media=\"screen\" type=\"text/css\">\n";
    
    // Limit the editor width if the full width setting is not enabled
    if (![[Options shared] editorFullWidth]) {
        headerStart = [headerStart stringByAppendingString:@".note-detail-markdown { max-width:750px;margin:0 auto; }"];
    }

    BOOL isDarkMode = SPUserInterface.isDark;
    
    // set main background and font color
    NSString *colorCSS = @"html { background-color: transparent; color: #%@ }\n";
    NSString *textHexColor = isDarkMode ? @"FFFFFF" : @"000000";
    headerStart = [headerStart stringByAppendingString:[NSString stringWithFormat:colorCSS, textHexColor]];

    NSString *headerEnd = @"</style></head><body><div class=\"note-detail-markdown\"><div id=\"static_content\">";
    NSString *path = [self cssPathForDarkMode:isDarkMode];
    NSString *css = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:path withExtension:nil]
                                             encoding:NSUTF8StringEncoding error:nil];
    
    return [[headerStart stringByAppendingString:css] stringByAppendingString:headerEnd];
}

+ (NSString *)cssPathForDarkMode:(BOOL)isDarkMode
{
    return isDarkMode ? @"markdown-dark.css" : @"markdown-default.css";
}

+ (NSString *)htmlFooter
{
    return @"</div></div></body></html>";
}

@end
